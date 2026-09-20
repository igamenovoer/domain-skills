#!/usr/bin/env bash
# kimi-project.sh — deploy and track Kimi Code accounts in project-scope data
# homes.
#
# Account "slots" are the long-lived Kimi data homes: ~/.kimi-code (slot
# "default") plus every directory under ~/kimi-homes/ (one per kimi-<suffix>
# launcher). This tool copies a slot's account state (config.toml +
# credentials/) into a project's .kimi-code/ home, tracks which account each
# slot is expected to hold, detects slots re-logged into a different account,
# and logs every deployment so later audits know where credentials live.
#
# Runtime state: ~/kimi-homes/manifest.json (all configurable state: account
# aliases and per-slot expected account + exclusion flag),
# ~/kimi-homes/deployments.jsonl (append-only deployment log), and per-home
# .backup/ directories: single-entry auth backups written by backup or by
# deploy --force-with-backup, read by restore. No token material is ever
# written to state files or printed. A slot whose "flags" is "excluded" is
# private: its credentials are never read, scanned, or deployed by any
# subcommand.
#
# Dependencies: bash, awk (any POSIX implementation), sed, GNU coreutils
# (base64, date, sort). No python, no jq binary. JSON reading uses the
# bundled JSON.awk parser below (https://github.com/step-/JSON.awk, v1.4.2),
# licensed MIT or Apache 2 per its source header.

set -euo pipefail

HOMES_ROOT="$HOME/kimi-homes"
MANIFEST="$HOMES_ROOT/manifest.json"
LOG_FILE="$HOMES_ROOT/deployments.jsonl"
DEFAULT_HOME="$HOME/.kimi-code"

die() { printf 'kimi-project: %s\n' "$1" >&2; exit 2; }

# ---------------------------------------------------------------------------
# Bundled JSON.awk parser (https://github.com/step-/JSON.awk, v1.4.2).
# Copyright (c) 2013-2020, step. License: MIT or Apache 2 (see the embedded
# source header). The parser source is embedded verbatim below, written to a
# temp file at startup, and removed on exit.

JSONAWK_FILE=$(mktemp "${TMPDIR:-/tmp}/jsonawk.XXXXXX.awk")
trap 'rm -f "$JSONAWK_FILE"' EXIT
cat > "$JSONAWK_FILE" <<'JSONAWK_EOF'
#!/usr/bin/awk -f
#
# Software: JSON.awk - a practical JSON parser written in awk
# Version: 1.4.2
# Copyright (c) 2013-2020, step
# License: MIT or Apache 2
# Project home: https://github.com/step-/JSON.awk
# Credits:      https://github.com/step-/JSON.awk#credits

# See README.md for full usage instructions.
# Usage:
#   awk [-v Option="value"...] -f JSON.awk "-" -or- Filepath [Filepath...]
#   printf "%s\n" Filepath [Filepath...] | awk [-v Option="value"...] -f JSON.awk
# Options: (default value in braces)
#    BRIEF=: 0 or M {1}:
#      non-zero excludes non-leaf nodes (array and object) from stdout; bit
#      mask M selects which to include of ""(1), "[]"(2) and "{}"(4), or
#      excludes ""(8) and wins over bit 1. BRIEF=0 includeѕ all.
#   STREAM=: 0 or 1 {1}:
#      zero hooks callbacks into parser and stdout printing.
#   STRICT=: 0,1,2 {0}:
#      1 enforce RFC8259#7 character escapes except for solidus '/'
#      2 enforce solidus escape too (for JSON embedded in HTML/XML)

BEGIN { #{{{1
	if (BRIEF  == "") BRIEF=1  # when 1 parse() omits non-leaf nodes from stdout
	if (STREAM == "") STREAM=1 # when 0 parse() stores JPATHS[] for callback cb_jpaths
	if (STRICT == "") STRICT=1 # when 1 parse() enforces valid character escapes (RFC8259 7)

	# Set if empty string/array/object go to stdout and cb_jpaths when BRIEF>0
	# defaults compatible with version up to 1.2
	NO_EMPTY_STR = 0; NO_EMPTY_ARY = NO_EMPTY_OBJ = 1
	#  leaf             non-leaf       non-leaf

	if (BRIEF > 0) { # parse() will look at NO_EMPTY_*
		NO_EMPTY_STR = !(x=bit_on(BRIEF, 0))
		NO_EMPTY_ARY = !(x=bit_on(BRIEF, 1))
		NO_EMPTY_OBJ = !(x=bit_on(BRIEF, 2))
		if (x=bit_on(BRIEF, 3)) NO_EMPTY_STR = 1 # wins over bit 0
	}

	# for each input file:
	#   TOKENS[], NTOKENS, ITOKENS - tokens after tokenize()
	#   JPATHS[], NJPATHS - parsed data (when STREAM=0)
	# at script exit:
	#   FAILS[] - maps names of invalid files to logged error lines
	delete FAILS
	reset()

	if (1 == ARGC) {
		# file pathnames from stdin
		# usage: echo -e "file1\nfile2\n" | awk -f JSON.awk
		# usage: { echo; cat file1; } | awk -f JSON.awk
		while (getline ARGV[++ARGC] < "/dev/stdin") {
			if (ARGV[ARGC] == "")
				break
		}
	} # else usage: awk -f JSON.awk file1 [file2...]

	# set file slurping mode
	srand(); RS="\1n/o/m/a/t/c/h" rand()
}

{ # main loop: process each file in turn {{{1
	reset() # See important application note in reset()

	++FILEINDEX # 1-based
	tokenize($0) # while(get_token()) {print TOKEN}
	if (0 == parse() && 0 == STREAM) {
		# Pass the callback an array of jpaths.
		cb_jpaths(JPATHS, NJPATHS)
	}
}

END { # process invalid files {{{1
	if (0 == STREAM) {
		# Pass the callback an associative array of failed objects.
		cb_fails(FAILS, NFAILS)
	}
	exit(NFAILS > 0)
}

function bit_on(n, b) { #{{{1
# Return n & (1 << b) for b>0 n>=0 - for awk portability
	if (b == 0) return n % 2
	return int(n / 2^b) % 2
}

function append_jpath_component(jpath, component) { #{{{1
	if (0 == STREAM) {
		return cb_append_jpath_component(jpath, component)
	} else {
		return (jpath != "" ? jpath "," : "") component
	}
}

function append_jpath_value(jpath, value) { #{{{1
	if (0 == STREAM) {
		return cb_append_jpath_value(jpath, value)
	} else {
		return sprintf("[%s]\t%s", jpath, value)
	}
}

function get_token() { #{{{1
# usage: {tokenize($0); while(get_token()) {print TOKEN}}

	# return getline TOKEN # for external tokenizer

	TOKEN = TOKENS[++ITOKENS] # for internal tokenize()
	return ITOKENS < NTOKENS  # 1 if more tokens to come
}

function parse_array_empty(jpath) { #{{{1
	if (0 == STREAM) {
		return cb_parse_array_empty(jpath)
	}
	return "[]"
}

function parse_array_enter(jpath) { #{{{1
	if (0 == STREAM) {
		cb_parse_array_enter(jpath)
	}
}

function parse_array_exit(jpath, status) { #{{{1
	if (0 == STREAM) {
		cb_parse_array_exit(jpath, status)
	}
}

function parse_array(a1,   idx,ary,ret) { #{{{1
	idx=0
	ary=""
	get_token()
#	print "parse_array(" a1 ") TOKEN=" TOKEN >"/dev/stderr"
	if (TOKEN != "]") {
		while (1) {
			if (ret = parse_value(a1, idx)) {
				return ret
			}
			idx=idx+1
			ary=ary VALUE
			get_token()
			if (TOKEN == "]") {
				break
			} else if (TOKEN == ",") {
				ary = ary ","
			} else {
				report(", or ]", TOKEN ? TOKEN : "EOF")
				return 2
			}
			get_token()
		}
		CB_VALUE = sprintf("[%s]", ary)
		# VALUE="" marks non-leaf jpath
		VALUE = 0 == BRIEF ? CB_VALUE : ""
	} else {
		VALUE = CB_VALUE = parse_array_empty(a1)
	}
	return 0
}

function parse_object_empty(jpath) { #{{{1
	if (0 == STREAM) {
		return cb_parse_object_empty(jpath)
	}
	return "{}"
}

function parse_object_enter(jpath) { #{{{1
	if (0 == STREAM) {
		cb_parse_object_enter(jpath)
	}
}

function parse_object_exit(jpath, status) { #{{{1
	if (0 == STREAM) {
		cb_parse_object_exit(jpath, status)
	}
}

function parse_object(a1,   key,obj) { #{{{1
	obj=""
	get_token()
#	print "parse_object(" a1 ") TOKEN=" TOKEN >"/dev/stderr"
	if (TOKEN != "}") {
		while (1) {
			if (TOKEN ~ /^".*"$/) {
				key=TOKEN
			} else {
				report("string", TOKEN ? TOKEN : "EOF")
				return 3
			}
			get_token()
			if (TOKEN != ":") {
				report(":", TOKEN ? TOKEN : "EOF")
				return 4
			}
			get_token()
			if (parse_value(a1, key)) {
				return 5
			}
			obj=obj key ":" VALUE
			get_token()
			if (TOKEN == "}") {
				break
			} else if (TOKEN == ",") {
				obj=obj ","
			} else {
				report(", or }", TOKEN ? TOKEN : "EOF")
				return 6
			}
			get_token()
		}
		CB_VALUE = sprintf("{%s}", obj)
		# VALUE="" marks non-leaf jpath
		VALUE = 0 == BRIEF ? CB_VALUE : ""
	} else {
		VALUE = CB_VALUE = parse_object_empty(a1)
	}
	return 0
}

function parse_value(a1, a2,   jpath,ret,x,reason) { #{{{1
	jpath = append_jpath_component(a1, a2)
#	print "parse_value(" a1 "," a2 ") TOKEN=" TOKEN " jpath=" jpath >"/dev/stderr"

	if (TOKEN == "{") {
		parse_object_enter(jpath)
		if (parse_object(jpath)) {
			parse_object_exit(jpath, 7)
			return 7
		}
		parse_object_exit(jpath, 0)
	} else if (TOKEN == "[") {
		parse_array_enter(jpath)
		if (ret = parse_array(jpath)) {
			parse_array_exit(jpath, ret)
			return ret
		}
		parse_array_exit(jpath, 0)
	} else if (TOKEN == "") { #test case 20150410 #4
		report("value", "EOF")
		return 8
	} else if ((x = is_value(TOKEN)) >0) {
		CB_VALUE = VALUE = TOKEN
	} else {
		if (-1 == x || -2 == x) {
			reason = "missing or invalid character escape"
		}
		report("value", TOKEN, reason)
		return 9
	}

	# jpath=="" occurs on starting and ending the parsing session.
	# VALUE=="" is set on parsing a non-empty array or a non-empty object.
	# Either condition is a reason to discard the parsed jpath if BRIEF>0.
	if (0 < BRIEF && ("" == jpath || "" == VALUE)) {
		return 0
	}

	# BRIEF>1 is a bit mask that selects if an empty string/array/object is passed on
	if (0 < BRIEF && (NO_EMPTY_STR && VALUE=="\"\"" || NO_EMPTY_ARY && VALUE=="[]" || NO_EMPTY_OBJ && VALUE=="{}")) {
		return 0
	}

	x = append_jpath_value(jpath, VALUE)
	if(0 == STREAM) {
		# save jpath+value for cb_jpaths
		JPATHS[++NJPATHS] = x
	} else {
		# consume jpath+value directly
		print x
	}
	return 0
}

function parse(   ret) { #{{{1
	get_token()
	if (ret = parse_value()) {
		return ret
	}
	if (get_token() || "" != TOKEN) {
		report("EOF", TOKEN)
		return 10
		# TODO the next JSON text starts here.
	}
	return 0
}

function report(expected, got, extra,   i,from,to,context) { #{{{1
	from = ITOKENS - 10; if (from < 1) from = 1
	to = ITOKENS + 10; if (to > NTOKENS) to = NTOKENS
	for (i = from; i < ITOKENS; i++)
		context = context sprintf("%s ", TOKENS[i])
	context = context "<<" got ">> "
	for (i = ITOKENS + 1; i <= to; i++)
		context = context sprintf("%s ", TOKENS[i])
	scream("expected <" expected "> but got <" got "> (length " length(got) (extra ? ", "extra :"") ") at input token " ITOKENS "\n" context)
}

function reset() { #{{{1
# Application Note:
# If you need to build JPATHS[] incrementally from multiple input files:
# 1) Comment out below:        delete JPATHS; NJPATHS=0
#    otherwise each new input file would reset JPATHS[].
# 2) Move the call to apply() from the main loop to the END statement.
# 3) In the main loop consider adding code that deletes partial JPATHS[]
#    elements that would result from parsing invalid JSON files.
# Compatibility Note:
# 1) Very old gawk versions: replace 'delete JPATHS' with 'split("", JPATHS)'.

	TOKEN=""; delete TOKENS; NTOKENS=ITOKENS=0
	delete JPATHS; NJPATHS=0
	CB_VALUE = VALUE = ""
}

function scream(msg) { #{{{1
	NFAILS += (FILENAME in FAILS ? 0 : 1)
	FAILS[FILENAME] = FAILS[FILENAME] (FAILS[FILENAME]!="" ? "\n" : "") msg
	if(0 == STREAM) {
		if(cb_fail1(msg)) {
			print FILENAME ": " msg >"/dev/stderr"
		}
	} else {
		print FILENAME ": " msg >"/dev/stderr"
	}
}

function tokenize(a1) { #{{{1
# usage A: {for(i=1; i<=tokenize($0); i++) print TOKENS[i]}
# see also get_token()

# Pattern string summary with adjustments:
# - replace strings with regex constant; https://github.com/step-/JSON.awk/issues/1
# - reduce [:cntrl:] to [\000-\037]; https://github.com/step-/JSON.awk/issues/5
# - reduce [:space:] to [ \t\n\r]; https://tools.ietf.org/html/rfc8259#page-5 ws
# - replace {4} quantifier with three [0-9a-fA-F] for mawk; https://unix.stackexchange.com/a/506125
# - UTF-8 BOM signature; https://en.wikipedia.org/wiki/Byte_order_mark#Byte_order_marks_by_encoding
# ----------
# 	TOKENS  = BOM "|" STRING "|" NUMBER "|" KEYWORD "|" SPACE "|."
# 	BOM     = "^\357\273\277"  # cf. issue #17
# 	STRING  = "\"" CHAR "*(" ESCAPE CHAR "*)*\""
# 	ESCAPE  = "(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})"
# 	CHAR    = "[^[:cntrl:]\\\"]"
# 	NUMBER  = "-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?"
# 	KEYWORD = "null|false|true"
# 	SPACE   = "[[:space:]]+"

	gsub(/^\357\273\277|"[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true|[ \t\n\r]+|./, "\n&", a1)
	gsub("\n" "[ \t\n\r]+", "\n", a1)
	# ^\n BOM or \n$?
	gsub(/^\n(\357\273\277\n)?|\n$/, "", a1)
	ITOKENS=0 # get_token() helper
	return NTOKENS = split(a1, TOKENS, /\n/)
}

function is_value(a1) { #{{{1
	# Return 0(malformed <value>) <0(<value> but !strict content) >0(pass)

	# STRING | NUMBER | KEYWORD
	if(!STRICT)
		return a1 ~ /^("[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*"|-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true)$/

	# STRICT is on
	# unescaped = %x20-21 / %x23-5B / %x5D-10FFFF
	# Characters in a STRING are restricted as follows (RFC8259):
	# All Unicode characters may be placed within the quotation marks, except for the characters that MUST be escaped:
	# quotation mark, reverse solidus, and the control characters (U+0000 through U+001F).
	# Any character may be escaped with \uXXXX, alternatively, with the following two-character escapes:
	# %x75 4HEXDIG    ; uXXXX                U+XXXX
	# %x22 /          ; "    quotation mark  U+0022
	# %x5C /          ; \    reverse solidus U+005C
	# %x62 /          ; b    backspace       U+0008
	# %x66 /          ; f    form feed       U+000C
	# %x6E /          ; n    line feed       U+000A   removed by tokenizer
	# %x72 /          ; r    carriage return U+000D   removed by tokenizer
	# %x2F /          ; /    solidus         U+002F   enforced only when STRICT >1
	# %x74 /          ; t    tab             U+0009   removed by tokenizer

	# NUMBER | KEYWORD
	if (1 != index(a1, "\"")) {
		return a1 ~ /^(-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?|null|false|true)$/
	}
	# invalid STRING
	if (a1 !~ /^("[^"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^"\\\000-\037]*)*")$/) {
		return 0
	}
	a1 = substr(a1, 2, length(a1) -2)

	# STRICT 1: allowed character escapes
	gsub(/\\["\\\/bfnrt]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]/, "", a1)
	# STRICT 1: unescaped quotation-mark, reverse solidus and control characters
	if (a1 ~ /["\\\000-\037]/) {
		return -1
	}
	# STRICT 2: unescaped solidus
	if (STRICT > 1 && index(a1, "/")) {
		return -2
	}
	# PASS STRICT STRING
	return 1
}

# vim:fdm=marker:
JSONAWK_EOF

# ajq FILE|- KEY [-s]   — top-level KEY lookup; -s unquotes/unescapes strings.
# Same call contract as the vcheckzen-bundled variant in kimi-project.sh.
ajq() {
    local v
    v=$(awk -f "$JSONAWK_FILE" "$1" 2>/dev/null \
        | awk -F'\t' -v k='["'"$2"'"]' \
            '$1 == k && !found { v = substr($0, index($0, "\t") + 1); found = 1 }
             END { if (found) print v }')
    if [ "${3:-}" = "-s" ]; then
        case $v in
            \"*\") v=${v#\"}; v=${v%\"} ;;
        esac
        printf '%s' "$v" | sed -e 's/\\"/"/g' -e 's/\\\\/\\/g'
    else
        printf '%s\n' "$v"
    fi
}
# ---------------------------------------------------------------------------
# Helpers

# --- manifest.json access (all configurable state lives here) ---------------
# Leaf lines from JSON.awk look like: ["aliases","main"]\t"dalvfs..."
# or ["slots","default","path"]\t"/home/...". Values read here are account
# ids, slot/alias names, and paths — quote/backslash escapes are not expected
# and are not decoded.

man_read() { # dump manifest leaf lines; empty when no manifest exists
    [ -f "$MANIFEST" ] || return 0
    awk -f "$JSONAWK_FILE" "$MANIFEST" 2>/dev/null
}

man_aliases() { # -> "name\tuid" lines
    man_read | awk -F'\t' '$1 ~ /^\["aliases","[^"]+"\]$/ {
        name = $1
        sub(/^\["aliases","/, "", name); sub(/"\]$/, "", name)
        v = substr($0, index($0, "\t") + 1)
        gsub(/^"|"$/, "", v)
        print name "\t" v
    }'
}

man_alias_get() { # NAME -> uid, empty when unbound
    man_aliases | awk -F'\t' -v k="$1" '$1 == k && !f { print $2; f = 1 }'
}

man_slots() { # -> "slot\tpath\texpected_uid\tflags\tupdated_at" lines
    man_read | awk -F'\t' '$1 ~ /^\["slots","[^"]+","[^"]+"\]$/ {
        line = $1
        sub(/^\["slots","/, "", line); sub(/"\]$/, "", line)
        split(line, parts, "\",\"")
        slot = parts[1]; field = parts[2]
        v = substr($0, index($0, "\t") + 1)
        gsub(/^"|"$/, "", v)
        seen[slot] = 1
        vals[slot, field] = v
    }
    END {
        for (s in seen)
            printf "%s\t%s\t%s\t%s\t%s\n", s, vals[s,"path"], vals[s,"expected_user_id"], vals[s,"flags"], vals[s,"updated_at"]
    }'
}

man_slot_field() { # SLOT FIELD -> value, empty when unset
    man_read | awk -F'\t' -v k='["slots","'"$1"'","'"$2"'"]' \
        '$1 == k && !f { v = substr($0, index($0, "\t") + 1); gsub(/^"|"$/, "", v); print v; f = 1 }'
}

slot_flags() { man_slot_field "$1" flags; }
slot_expected() { man_slot_field "$1" expected_user_id; }

is_excluded() { # SLOT -> rc 0 when the slot is flagged excluded (private)
    [ "$(slot_flags "$1")" = "excluded" ]
}

excluded_homes() { # home paths of excluded slots
    man_slots | awk -F'\t' '$4 == "excluded" { print $2 }'
}

is_excluded_home() { # PATH -> rc 0 when PATH is an excluded slot's home
    excluded_homes | grep -x -F -- "$1" >/dev/null
}

manifest_write() { # ALIASES_FILE SLOTS_FILE — atomically regenerate manifest.json
    # Slot lines are "slot\tpath\texpected_uid\tflags\tupdated_at"; flags may
    # be empty, so fields are parsed with awk (read with IFS=tab would
    # collapse consecutive tabs and shift the columns).
    mkdir -p "$HOMES_ROOT"
    local tmp
    tmp=$(mktemp)
    awk -F'\t' '
        function jesc(s) { gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s); return s }
        FILENAME == ARGV[1] {
            if ($1 != "") { na++; an[na] = $1; av[na] = $2 }
            next
        }
        $1 != "" { ns++; sn[ns] = $1; sp[ns] = $2; se[ns] = $3; sf[ns] = $4; su[ns] = $5 }
        END {
            print "{"
            print "  \"version\": 1,"
            if (na == 0) {
                print "  \"aliases\": {},"
            } else {
                print "  \"aliases\": {"
                for (i = 1; i <= na; i++)
                    printf "    \"%s\": \"%s\"%s\n", jesc(an[i]), jesc(av[i]), (i < na ? "," : "")
                print "  },"
            }
            if (ns == 0) {
                print "  \"slots\": {}"
            } else {
                print "  \"slots\": {"
                for (i = 1; i <= ns; i++) {
                    printf "    \"%s\": {\n", jesc(sn[i])
                    printf "      \"path\": \"%s\",\n", jesc(sp[i])
                    printf "      \"expected_user_id\": \"%s\",\n", jesc(se[i])
                    printf "      \"flags\": \"%s\",\n", jesc(sf[i])
                    printf "      \"updated_at\": \"%s\"\n", jesc(su[i])
                    printf "    }%s\n", (i < ns ? "," : "")
                }
                print "  }"
            }
            print "}"
        }
    ' "$1" "$2" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$MANIFEST"
}

man_alias_set() { # NAME UID — bind, or delete when UID is empty
    local name=$1 uid=$2 tmpa tmps
    tmpa=$(mktemp); tmps=$(mktemp)
    man_aliases | awk -F'\t' -v k="$name" '$1 != k' > "$tmpa"
    [ -n "$uid" ] && printf '%s\t%s\n' "$name" "$uid" >> "$tmpa"
    man_slots > "$tmps"
    manifest_write "$tmpa" "$tmps"
    rm -f "$tmpa" "$tmps"
}

man_slot_set() { # SLOT PATH EXPECTED_UID FLAGS — replace/insert a slot entry
    local slot=$1 path=$2 expected=$3 flags=$4 tmpa tmps
    tmpa=$(mktemp); tmps=$(mktemp)
    man_aliases > "$tmpa"
    man_slots | awk -F'\t' -v k="$slot" '$1 != k' > "$tmps"
    printf '%s\t%s\t%s\t%s\t%s\n' \
        "$slot" "$path" "$expected" "$flags" "$(date +%Y-%m-%dT%H:%M:%S)" >> "$tmps"
    manifest_write "$tmpa" "$tmps"
    rm -f "$tmpa" "$tmps"
}

fmt_age() { # seconds -> 6d2h / 2h6m / 5m
    local s=${1%.*} d h m
    [ "$s" -lt 0 ] 2>/dev/null && s=0
    d=$((s / 86400)); h=$(( (s % 86400) / 3600 )); m=$(( (s % 3600) / 60 ))
    if [ "$d" -gt 0 ]; then printf '%sd%sh' "$d" "$h"
    elif [ "$h" -gt 0 ]; then printf '%sh%sm' "$h" "$m"
    else printf '%sm' "$m"; fi
}

short_uid() { printf '%s' "${1:0:8}"; }

json_escape() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }

jwt_payload_json() { # decode segment 2 of a JWT; prints payload JSON
    local p=${1#*.}
    p=${p%%.*}
    p=$(printf '%s' "$p" | tr -- '_-' '/+')
    case $(( ${#p} % 4 )) in
        0) ;;
        2) p="$p==" ;;
        3) p="$p=" ;;
        *) return 1 ;;
    esac
    printf '%s' "$p" | base64 -d 2>/dev/null
}

cred_info() { # CRED_FILE -> "user_id\tiat\texp"; rc 1 when unreadable
    local f=$1 tok payload uid iat exp
    tok=$(ajq "$f" refresh_token -s 2>/dev/null || true)
    [ -n "$tok" ] && [ "$tok" != "null" ] || return 1
    payload=$(jwt_payload_json "$tok") || return 1
    [ -n "$payload" ] || return 1
    uid=$(printf '%s' "$payload" | ajq - user_id -s 2>/dev/null || true)
    if [ -z "$uid" ] || [ "$uid" = "null" ]; then
        uid=$(printf '%s' "$payload" | ajq - sub -s 2>/dev/null || true)
    fi
    [ -n "$uid" ] && [ "$uid" != "null" ] || return 1
    iat=$(printf '%s' "$payload" | ajq - iat 2>/dev/null || true)
    exp=$(printf '%s' "$payload" | ajq - exp 2>/dev/null || true)
    case "$iat$exp" in *[!0-9]* | '') return 1 ;; esac
    printf '%s\t%s\t%s\n' "$uid" "$iat" "$exp"
}

home_creds() { # HOME -> lines "user_id\tiat\trefresh_exp\tcred_file"
    local home=$1 f info
    [ -d "$home/credentials" ] || return 0
    for f in "$home/credentials"/*.json; do
        [ -e "$f" ] || continue
        if info=$(cred_info "$f"); then
            printf '%s\t%s\n' "$info" "$f"
        else
            printf 'warning: skipped %s: unreadable credential\n' "$f" >&2
        fi
    done
}

slot_current() { # HOME -> freshest cred line (as home_creds), empty when none
    home_creds "$1" | awk -F'\t' '{ if (NR == 1 || $2+0 > max) { max = $2+0; line = $0 } } END { if (NR > 0) print line }'
}

slot_home() { # SLOT -> home path, empty when unknown (never early-closes the pipe)
    discover_slots | awk -F'\t' -v k="$1" '$1 == k && found == 0 { print $2; found = 1 }'
}

project_dir() { # resolved project dir for project-scoped commands
    local d
    d=$(cd "${OPT_PROJECT:-.}" 2>/dev/null && pwd -P) \
        || die "project directory not found: ${OPT_PROJECT:-.}"
    printf '%s\n' "$d"
}

resolve_home() { # FALLBACK(default|cwd) — --project DIR > $KIMI_CODE_HOME > fallback
    local fb=$1
    if [ -n "$OPT_PROJECT" ]; then
        local d
        d=$(project_dir) || return 2
        printf '%s/.kimi-code\n' "$d"
    elif [ -n "${KIMI_CODE_HOME:-}" ]; then
        if [ -d "$KIMI_CODE_HOME" ]; then
            (cd "$KIMI_CODE_HOME" && pwd -P)
        else
            printf '%s\n' "$KIMI_CODE_HOME"
        fi
    elif [ "$fb" = default ]; then
        printf '%s\n' "$DEFAULT_HOME"
    else
        local d
        d=$(project_dir) || return 2
        printf '%s/.kimi-code\n' "$d"
    fi
}

target_home() { # backup/restore target: --project DIR > $KIMI_CODE_HOME > ~/.kimi-code
    resolve_home default
}

deploy_home() { # deploy target: --project DIR > $KIMI_CODE_HOME > cwd/.kimi-code
    resolve_home cwd
}

discover_slots() { # prints "name\thome" lines
    printf 'default\t%s\n' "$DEFAULT_HOME"
    local d
    [ -d "$HOMES_ROOT" ] || return 0
    for d in "$HOMES_ROOT"/*/; do
        [ -d "$d" ] || continue
        case $(basename "$d") in .*) continue ;; esac
        printf '%s\t%s\n' "$(basename "$d")" "${d%/}"
    done
}

logged_deploy_homes() { # unique deploy-target homes from the log (new: home=, legacy: project=)
    [ -f "$LOG_FILE" ] || return 0
    local line action project home
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        action=$(printf '%s' "$line" | ajq - action -s 2>/dev/null || true)
        [ "$action" = "deploy" ] || continue
        home=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
        if [ -n "$home" ] && [ "$home" != "null" ]; then
            printf '%s\n' "$home"
            continue
        fi
        project=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
        if [ -n "$project" ] && [ "$project" != "null" ]; then
            printf '%s/.kimi-code\n' "$project"
        fi
    done < "$LOG_FILE" | sort -u
}

collect_copies() { # all cred copies: slots (minus excluded) + logged deploy homes
    local name home dhome
    discover_slots | while IFS=$'\t' read -r name home; do
        is_excluded "$name" && continue
        home_creds "$home"
    done
    logged_deploy_homes | while IFS= read -r dhome; do
        home_creds "$dhome"
    done
}

path_creds() { # ROOT -> cred copies under a home, a project, or a parent of projects
    local root=${1%/} d
    if is_excluded_home "$root"; then
        printf 'note: %s is excluded (private); skipped\n' "$root" >&2
        return 0
    fi
    home_creds "$root"
    if is_excluded_home "$root/.kimi-code"; then
        printf 'note: %s is excluded (private); skipped\n' "$root/.kimi-code" >&2
    else
        home_creds "$root/.kimi-code"
    fi
    for d in "$root"/*/; do
        [ -d "$d" ] || continue
        is_excluded_home "${d%/}/.kimi-code" && continue
        home_creds "${d%/}/.kimi-code"
    done
}

last_deploy_entry() { # TARGET_HOME -> newest deploy log line for it, empty when none
    [ -f "$LOG_FILE" ] || return 0
    local line action proj home
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        action=$(printf '%s' "$line" | ajq - action -s 2>/dev/null || true)
        [ "$action" = "deploy" ] || continue
        home=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
        if [ -z "$home" ] || [ "$home" = "null" ]; then
            proj=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
            if [ -n "$proj" ] && [ "$proj" != "null" ]; then
                home="$proj/.kimi-code"
            else
                home=
            fi
        fi
        if [ "$home" = "$1" ]; then
            printf '%s\n' "$line"
        fi
    done < "$LOG_FILE" | tail -n 1
}

aliases_for_uid() { # USER_ID -> comma-joined alias names
    man_aliases | awk -F'\t' -v uid="$1" '$2 == uid { print $1 }' | sort | paste -sd, -
}

slot_state() { # SLOT CURRENT_LINE -> state text
    local slot=$1 current=$2 expected path updated
    is_excluded "$slot" && { printf 'excluded (private)'; return 0; }
    [ -n "$current" ] || { printf 'empty'; return 0; }
    expected=$(slot_expected "$slot")
    if [ -z "$expected" ]; then
        printf 'untracked (register with: register %s AUTH_JSON)' "$slot"
        return 0
    fi
    local uid
    uid=$(printf '%s' "$current" | cut -f1)
    if [ "$expected" != "$uid" ]; then
        local al
        al=$(aliases_for_uid "$expected")
        [ -n "$al" ] && al=" ($al)"
        printf 'DRIFTED — expected %s%s, holds %s' "$(short_uid "$expected")" "$al" "$(short_uid "$uid")"
    else
        printf 'ok'
    fi
}

freshest_for_uid() { # COPIES_TSV_FILE USER_ID -> freshest line, empty when none
    awk -F'\t' -v uid="$2" '$1 == uid { if (max == "" || $2+0 > max) { max = $2+0; line = $0 } } END { if (line != "") print line }' "$1"
}

project_has_home() { # PROJECT_HOME
    [ -e "$1/config.toml" ] || [ -e "$1/credentials" ]
}

append_log() { # ACTION key=value ...  (ts/cred_iat values written as numbers)
    local action=$1; shift
    mkdir -p "$HOMES_ROOT"
    local epoch now line kv k v
    epoch=$(date +%s)
    now=$(date -d "@$epoch" +%Y-%m-%dT%H:%M:%S)
    line=$(printf '{"ts":%s,"time":"%s","action":"%s"' \
        "$epoch" "$(json_escape "$now")" "$(json_escape "$action")")
    for kv in "$@"; do
        k=${kv%%=*}; v=${kv#*=}
        case $k in
            ts | cred_iat) line=$line$(printf ',"%s":%s' "$k" "${v:-0}") ;;
            *) line=$line$(printf ',"%s":"%s"' "$(json_escape "$k")" "$(json_escape "$v")") ;;
        esac
    done
    printf '%s}\n' "$line" >> "$LOG_FILE"
    chmod 600 "$LOG_FILE"
}

# ---------------------------------------------------------------------------
# Read-only commands

cmd_list() {
    local now name home current uid aliases refreshed ttl state
    now=$(date +%s)
    printf 'slots:\n'
    printf '  %-14s %-10s %-10s %-10s %-7s state\n' name alias account refreshed TTL
    discover_slots | while IFS=$'\t' read -r name home; do
        if is_excluded "$name"; then
            printf '  %-14s %-10s %-10s %-10s %-7s %s\n' \
                "$name" - - - - "excluded (private) — credentials not read"
            continue
        fi
        current=$(slot_current "$home" || true)
        if [ -n "$current" ]; then
            uid=$(printf '%s' "$current" | cut -f1)
            aliases=$(aliases_for_uid "$uid"); aliases=${aliases:--}
            refreshed="$(fmt_age $((now - $(printf '%s' "$current" | cut -f2)))) ago"
            ttl=$(fmt_age $(( $(printf '%s' "$current" | cut -f3) - now )))
        else
            uid=-; aliases=-; refreshed=-; ttl=-
        fi
        state=$(slot_state "$name" "$current")
        printf '  %-14s %-10s %-10s %-10s %-7s %s\n' \
            "$name" "$aliases" "$(short_uid "$uid")" "$refreshed" "$ttl" "$state"
    done

    [ -f "$MANIFEST" ] || return 0
    local copies uid_prefix
    copies=$(mktemp)
    collect_copies > "$copies"
    printf '\naliases:\n'
    man_aliases | while IFS=$'\t' read -r name uid; do
        [ -n "$name" ] || continue
        local best
        best=$(freshest_for_uid "$copies" "$uid" || true)
        if [ -n "$best" ]; then
            local best_home iat
            iat=$(printf '%s' "$best" | cut -f2)
            best_home=$(dirname "$(dirname "$(printf '%s' "$best" | cut -f4)")")
            printf '  %-10s %-10s freshest: %s (%s ago)\n' \
                "$name" "$(short_uid "$uid")" "$best_home" "$(fmt_age $((now - iat)))"
            awk -F'\t' -v uid="$uid" '$1 == uid { print $4 }' "$copies" \
                | sort -u | while IFS= read -r f; do
                printf '  %-10s %-10s copy:     %s\n' '' '' "$(dirname "$(dirname "$f")")"
            done
        else
            if man_slots | awk -F'\t' -v uid="$uid" '$4 == "excluded" && $3 == uid { found = 1 } END { exit !found }'; then
                printf '  %-10s %-10s private — held only by an excluded slot, unavailable for deploy\n' \
                    "$name" "$(short_uid "$uid")"
            else
                printf '  %-10s %-10s MISSING — no slot or logged project holds this account\n' \
                    "$name" "$(short_uid "$uid")"
            fi
        fi
    done
    rm -f "$copies"
}

cmd_status() { # [--project DIR]
    local project home now current uid iat exp aliases
    project=$(project_dir)
    home="$project/.kimi-code"
    now=$(date +%s)

    if ! project_has_home "$home"; then
        printf '%s: no project home (deploy or new to create one)\n' "$project"
        return 0
    fi
    printf 'project: %s\n' "$project"
    current=$(slot_current "$home" || true)
    if [ -z "$current" ]; then
        printf '  home exists but has no readable credentials\n'
        return 0
    fi
    uid=$(printf '%s' "$current" | cut -f1)
    iat=$(printf '%s' "$current" | cut -f2)
    exp=$(printf '%s' "$current" | cut -f3)
    aliases=$(aliases_for_uid "$uid")
    [ -n "$aliases" ] && aliases=" ($aliases)"
    printf '  account: %s%s\n' "$(short_uid "$uid")" "$aliases"
    printf '  refreshed: %s ago; refresh token TTL %s\n' "$(fmt_age $((now - iat)))" "$(fmt_age $((exp - now)))"

    local last deployed_uid
    last=$(last_deploy_entry "$home")
    if [ -n "$last" ]; then
        printf '  last deployed: %s from %s\n' \
            "$(printf '%s' "$last" | ajq - time -s)" "$(printf '%s' "$last" | ajq - source_home -s)"
        deployed_uid=$(printf '%s' "$last" | ajq - user_id -s)
        if [ -n "$deployed_uid" ] && [ "$deployed_uid" != "$uid" ]; then
            printf '  DRIFTED — deployed as %s, now holds %s\n' \
                "$(short_uid "$deployed_uid")" "$(short_uid "$uid")"
        fi
    else
        printf '  last deployed: never (no log entry for this project)\n'
    fi

    local copies best cred_file
    copies=$(mktemp); collect_copies > "$copies"
    best=$(freshest_for_uid "$copies" "$uid" || true)
    cred_file=$(printf '%s' "$current" | cut -f4)
    if [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f4)" != "$cred_file" ] \
        && [ "$(printf '%s' "$best" | cut -f2)" -gt "$iat" ]; then
        printf '  stale — a fresher copy exists at %s (newer by %s)\n' \
            "$(dirname "$(dirname "$(printf '%s' "$best" | cut -f4)")")" \
            "$(fmt_age $(( $(printf '%s' "$best" | cut -f2) - iat )))"
    else
        printf '  this copy is the freshest known for its account\n'
    fi
    rm -f "$copies"
}

fmt_log_line() { # LINE -> compact rendering of a deployment-log entry
    local line=$1 time_s action uid project source backup home out
    time_s=$(printf '%s' "$line" | ajq - time -s)
    action=$(printf '%s' "$line" | ajq - action -s)
    uid=$(printf '%s' "$line" | ajq - user_id -s 2>/dev/null || true)
    project=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
    source=$(printf '%s' "$line" | ajq - source_home -s 2>/dev/null || true)
    backup=$(printf '%s' "$line" | ajq - backup -s 2>/dev/null || true)
    home=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
    [ "$uid" = "null" ] && uid=
    out="$time_s  $(printf '%-7s' "$action")"
    [ -n "$uid" ] && out="$out  $(short_uid "$uid")"
    [ -n "$project" ] && [ "$project" != "null" ] && out="$out  $project"
    [ -n "$home" ] && [ "$home" != "null" ] && out="$out  $home"
    [ -n "$source" ] && [ "$source" != "null" ] && out="$out  from $source"
    [ -n "$backup" ] && [ "$backup" != "null" ] && out="$out  backup $backup"
    printf '%s\n' "$out"
}

cmd_log() { # [COUNT]
    local count=${1:-20} line
    [ -f "$LOG_FILE" ] || { printf 'deployment log is empty\n'; return 0; }
    tail -n "$count" "$LOG_FILE" | while IFS= read -r line; do
        [ -n "$line" ] || continue
        fmt_log_line "$line"
    done
}

cmd_scan() { # [PATH ...] — extra roots: a home, a project, or a parent of projects
    local now copies extra
    now=$(date +%s)
    copies=$(mktemp)
    { collect_copies
      for extra in "$@"; do
          [ -d "$extra" ] || { printf 'warning: scan path skipped (not a directory): %s\n' "$extra" >&2; continue; }
          path_creds "$extra"
      done
    } | sort -u > "$copies"

    printf '== account freshness\n'
    if [ -s "$copies" ]; then
        printf 'distinct accounts: %s   credential files: %s\n' \
            "$(cut -f1 "$copies" | sort -u | wc -l)" "$(wc -l < "$copies")"
        awk -F'\t' -v now="$now" '
            function age(s,  d,h,m) {
                if (s < 0) s = 0
                d = int(s/86400); h = int((s%86400)/3600); m = int((s%3600)/60)
                if (d > 0) return d "d" h "h"
                if (h > 0) return h "h" m "m"
                return m "m"
            }
            NR == FNR { if ($1 != "") cnt[$1]++; next }
            $1 != prev {
                if (acct > 0) print ""
                acct++; prev = $1; first_iat = $2
                printf "account #%d: user_id=%s  (%d cop%s)\n", acct, $1, cnt[$1], (cnt[$1] > 1 ? "ies" : "y")
                printf "  latest: %s\n", $4
                printf "          refreshed %s ago, refresh token expires in %s%s\n", \
                    age(now-$2), age($3-now), ($3 < now ? " [refresh EXPIRED]" : "")
                next
            }
            {
                printf "  stale:  %s (behind by %s)%s\n", $4, age(first_iat-$2), \
                    ($3 < now ? " [refresh EXPIRED]" : "")
            }
        ' "$copies" <(sort -t "$(printf '\t')" -k1,1 -k2,2nr "$copies")
    else
        printf 'no credential files found\n'
    fi

    printf '\n== drift check\n'
    local name home current state dhome deployed_uid last uid aline drift_out
    drift_out=$(
        discover_slots | while IFS=$'\t' read -r name home; do
            is_excluded "$name" && continue
            current=$(slot_current "$home" || true)
            state=$(slot_state "$name" "$current")
            case $state in ok | empty) ;; *) printf '  slot %s: %s\n' "$name" "$state" ;; esac
        done
        logged_deploy_homes | while IFS= read -r dhome; do
            project_has_home "$dhome" || continue
            current=$(slot_current "$dhome" || true)
            [ -n "$current" ] || continue
            last=$(last_deploy_entry "$dhome")
            [ -n "$last" ] || continue
            deployed_uid=$(printf '%s' "$last" | ajq - user_id -s)
            uid=$(printf '%s' "$current" | cut -f1)
            if [ -n "$deployed_uid" ] && [ "$deployed_uid" != "$uid" ]; then
                printf '  home %s: DRIFTED — deployed as %s, now holds %s\n' \
                    "$dhome" "$(short_uid "$deployed_uid")" "$(short_uid "$uid")"
            fi
        done
        man_aliases | while IFS=$'\t' read -r aline uid; do
            [ -n "$aline" ] || continue
            if [ -z "$(freshest_for_uid "$copies" "$uid" || true)" ]; then
                printf '  alias %s: account %s missing everywhere\n' "$aline" "$(short_uid "$uid")"
            fi
        done
    )
    if [ -n "$drift_out" ]; then
        printf '%s\n' "$drift_out"
    else
        printf '  no drift detected\n'
    fi
    rm -f "$copies"
}

# ---------------------------------------------------------------------------
# Mutating commands

cmd_register() { # SLOT AUTH_JSON — declare the account a slot is expected to hold
    local slot=$1 cred=$2 home uid old current cred_home
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    is_excluded "$slot" && die "slot '$slot' is excluded (private); run 'include $slot' before registering it"
    [ -f "$cred" ] || die "credential file not found: $cred"
    cred=$(cd "$(dirname "$cred")" && pwd -P)/$(basename "$cred")
    cred_home=$(dirname "$(dirname "$cred")")
    if is_excluded_home "$cred_home"; then
        local xslot
        xslot=$(man_slots | awk -F'\t' -v p="$cred_home" '$4 == "excluded" && $2 == p && !f { print $1; f = 1 }')
        die "$cred belongs to excluded slot '$xslot' (private); its credentials are never read. Run 'include $xslot' to lift this."
    fi
    local info
    info=$(cred_info "$cred") || die "unreadable credential: $cred"
    uid=$(printf '%s' "$info" | cut -f1)
    old=$(slot_expected "$slot")
    man_slot_set "$slot" "$home" "$uid" "$(slot_flags "$slot")"
    if [ -n "$old" ] && [ "$old" != "$uid" ]; then
        printf 're-registered %s: expected account was %s, now %s\n' "$slot" "$(short_uid "$old")" "$(short_uid "$uid")"
    else
        printf 'registered %s: expected account %s\n' "$slot" "$uid"
    fi
    current=$(slot_current "$home" || true)
    if [ -n "$current" ]; then
        if [ "$(printf '%s' "$current" | cut -f1)" != "$uid" ]; then
            printf 'note: %s currently holds %s — it will show DRIFTED until re-logged into %s\n' \
                "$slot" "$(short_uid "$(printf '%s' "$current" | cut -f1)")" "$(short_uid "$uid")"
        fi
    else
        printf 'note: %s currently has no readable credentials; it will show empty until logged in\n' "$slot"
    fi
}

cmd_exclude() { # SLOT — never read, scan, or deploy from this slot's home
    local slot=$1 home expected aliases
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    if is_excluded "$slot"; then
        printf 'slot %s is already excluded\n' "'$slot'"
        return 0
    fi
    expected=$(slot_expected "$slot")
    man_slot_set "$slot" "$home" "$expected" "excluded"
    printf 'excluded %s (%s)\n' "'$slot'" "$home"
    printf '  its credentials will not be read, scanned, or deployed by any subcommand\n'
    printf '  undo with: kimi-project.sh include %s\n' "$slot"
    if [ -n "$expected" ]; then
        aliases=$(aliases_for_uid "$expected")
        if [ -n "$aliases" ]; then
            printf '  note: alias(es) %s point to this account; deploys by alias will fail while it exists only here\n' "$aliases"
        fi
    fi
}

cmd_include() { # SLOT — clear the exclusion flag
    local slot=$1 home expected
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    is_excluded "$slot" || { printf 'slot %s is not excluded\n' "'$slot'"; return 0; }
    expected=$(slot_expected "$slot")
    man_slot_set "$slot" "$home" "$expected" ""
    printf 'included %s (%s); it is readable, scannable, and deployable again\n' "'$slot'" "$home"
}

cmd_alias() { # NAME SLOT [--force]
    local name=$1 slot=$2 home current uid existing tmp
    case $name in
        [a-z0-9] | [a-z0-9]*[a-z0-9-]) ;;
        *) die "alias '$name' must be lowercase letters, digits, hyphens" ;;
    esac
    printf '%s' "$name" | grep -q '^[a-z0-9][a-z0-9-]*$' \
        || die "alias '$name' must be lowercase letters, digits, hyphens"
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'"
    is_excluded "$slot" && die "slot '$slot' is excluded (private); run 'include $slot' before aliasing its account"
    current=$(slot_current "$home" || true)
    [ -n "$current" ] || die "slot '$slot' has no readable credentials — log in first"
    uid=$(printf '%s' "$current" | cut -f1)
    existing=$(man_alias_get "$name")
    if [ -n "$existing" ] && [ "$existing" != "$uid" ] && [ "$OPT_FORCE" != 1 ]; then
        die "alias '$name' already points to $(short_uid "$existing"); use --force to rebind to $(short_uid "$uid")"
    fi
    man_alias_set "$name" "$uid"
    printf 'alias %s -> %s (account currently in slot %s)\n' "$name" "$uid" "'$slot'"
}

cmd_unalias() { # NAME
    local name=$1 existing
    existing=$(man_alias_get "$name")
    [ -n "$existing" ] || die "no alias '$name'"
    man_alias_set "$name" ""
    printf 'removed alias %s (was %s)\n' "$name" "$(short_uid "$existing")"
}

resolve_selector() { # SELECTOR COPIES_FILE -> "account\tUID" or "slot\tNAME"
    local sel=$1 copies=$2 uid matches
    uid=$(man_alias_get "$sel")
    if [ -n "$uid" ]; then printf 'account\t%s\n' "$uid"; return 0; fi
    if discover_slots | cut -f1 | grep -x -F -- "$sel" >/dev/null; then printf 'slot\t%s\n' "$sel"; return 0; fi
    matches=$(awk -F'\t' -v p="$sel" 'index($1, p) == 1 { print $1 }' "$copies" | sort -u)
    case $(printf '%s\n' "$matches" | grep -c .) in
        1) printf 'account\t%s\n' "$matches" ;;
        0) die "unknown selector '$sel'. Valid: $( { man_aliases | cut -f1; discover_slots | cut -f1; } | sort -u | paste -sd' ' -)" ;;
        *) die "selector '$sel' is ambiguous between accounts: $(printf '%s\n' "$matches" | while read -r m; do short_uid "$m"; done | paste -sd' ' -)" ;;
    esac
}

holds_freshest_copy() { # HOME -> rc 0 when HOME holds the freshest known copy of its account
    local home=$1 current uid copies best
    current=$(slot_current "$home" || true)
    [ -n "$current" ] || return 1
    uid=$(printf '%s' "$current" | cut -f1)
    copies=$(mktemp); collect_copies > "$copies"
    best=$(freshest_for_uid "$copies" "$uid" || true)
    rm -f "$copies"
    [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f4)" = "$(printf '%s' "$current" | cut -f4)" ]
}

backup_home() { # HOME — copy a home's auth into <home>/.backup/ (single entry, overwrite)
    local home=$1 tmp replaced
    tmp="$home/.backup.tmp.$$"
    rm -rf "$tmp"
    mkdir -p "$tmp"
    if [ -e "$home/config.toml" ]; then
        cp -p "$home/config.toml" "$tmp/config.toml"
        chmod 600 "$tmp/config.toml"
    fi
    if [ -d "$home/credentials" ]; then
        mkdir -p "$tmp/credentials"
        chmod 700 "$tmp/credentials"
        cp -a "$home/credentials/." "$tmp/credentials/"
        find "$tmp/credentials" -type f -exec chmod 600 {} +
    fi
    replaced=
    if [ -e "$home/.backup" ]; then
        replaced=1
        rm -rf "$home/.backup"
    fi
    mv "$tmp" "$home/.backup"
    if [ -n "$replaced" ]; then
        printf 'note: replaced the previous backup at %s (single backup entry per home)\n' \
            "$home/.backup"
    fi
}

require_clear_or_forced() { # HOME — occupied-home gate for deploy/new
    project_has_home "$1" || return 0
    [ "$OPT_FORCE" = 1 ] || die "$1 already holds an account.
Use --force to overwrite it (no backup), or --force-with-backup to back it up to .backup/ first."
}

replace_home_auth() { # HOME — forced replace: warn, back up when asked, then clear auth
    local home=$1 current uid
    if holds_freshest_copy "$home"; then
        if [ "$OPT_FORCE_BACKUP" = 1 ]; then
            printf 'note: %s holds the freshest known copy of its account; it is preserved in .backup/\n' \
                "$home"
        else
            printf 'warning: %s holds the freshest known copy of its account; overwriting with no backup\n' \
                "$home"
        fi
    fi
    if [ "$OPT_FORCE_BACKUP" = 1 ]; then
        current=$(slot_current "$home" || true)
        uid=
        if [ -n "$current" ]; then
            uid=$(printf '%s' "$current" | cut -f1)
        fi
        backup_home "$home"
        append_log backup "user_id=$uid" "home=$home"
        printf 'previous auth backed up to %s\n' "$home/.backup"
    fi
    rm -f "$home/config.toml"
    rm -rf "$home/credentials"
}

cmd_deploy() { # SELECTOR [--from SLOT] [--force|--force-with-backup] [--project DIR]
    local sel=$1 home now copies via_env
    if [ -z "$OPT_PROJECT" ] && [ -n "${KIMI_CODE_HOME:-}" ]; then
        via_env=1
    else
        via_env=
    fi
    home=$(deploy_home)
    if is_excluded_home "$home"; then
        local xslot
        xslot=$(man_slots | awk -F'\t' -v p="$home" '$4 == "excluded" && $2 == p && !f { print $1; f = 1 }')
        die "$home is excluded (private); deploy would touch its credentials. Run 'include $xslot' to lift this."
    fi
    require_clear_or_forced "$home"
    now=$(date +%s)
    copies=$(mktemp)
    collect_copies > "$copies"

    local source source_home uid iat exp cred_file
    if [ -n "$OPT_FROM" ]; then
        is_excluded "$OPT_FROM" && die "slot '$OPT_FROM' is excluded (private); it is never a deploy source. Run 'include $OPT_FROM' to lift this."
        source_home=$(slot_home "$OPT_FROM")
        [ -n "$source_home" ] || die "unknown slot '$OPT_FROM'"
        source=$(slot_current "$source_home" || true)
        [ -n "$source" ] || die "slot '$OPT_FROM' has no readable credentials — log in first"
        uid=$(printf '%s' "$source" | cut -f1)
        local expected
        expected=$(slot_expected "$OPT_FROM")
        if [ -n "$expected" ] && [ "$expected" != "$uid" ] && [ "$OPT_FORCE" != 1 ]; then
            die "slot '$OPT_FROM' is DRIFTED: expected $(short_uid "$expected"), holds $(short_uid "$uid"). Use --force to deploy anyway."
        fi
        local best best_iat
        best=$(freshest_for_uid "$copies" "$uid" || true)
        best_iat=$(printf '%s' "$best" | cut -f2)
        if [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f4)" != "$(printf '%s' "$source" | cut -f4)" ] \
            && [ "$best_iat" -gt "$(printf '%s' "$source" | cut -f2)" ] && [ "$OPT_FORCE" != 1 ]; then
            rm -f "$copies"
            die "slot '$OPT_FROM' is not the freshest copy of $(short_uid "$uid"); $(dirname "$(dirname "$(printf '%s' "$best" | cut -f4)")") is newer by $(fmt_age $((best_iat - $(printf '%s' "$source" | cut -f2)))).
Deploy from there instead (selector: $(short_uid "$uid")), or use --force."
        fi
    else
        local kind value best
        local resolved
        resolved=$(resolve_selector "$sel" "$copies")
        kind=$(printf '%s' "$resolved" | cut -f1)
        value=$(printf '%s' "$resolved" | cut -f2)
        if [ "$kind" = "slot" ]; then
            is_excluded "$value" && die "slot '$value' is excluded (private); it is never a deploy source. Run 'include $value' to lift this."
            source_home=$(slot_home "$value")
            source=$(slot_current "$source_home" || true)
            [ -n "$source" ] || die "slot '$value' has no readable credentials — log in first"
            best=$(freshest_for_uid "$copies" "$(printf '%s' "$source" | cut -f1)" || true)
            [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f2)" -gt "$(printf '%s' "$source" | cut -f2)" ] && source=$best
        else
            source=$(freshest_for_uid "$copies" "$value" || true)
            if [ -z "$source" ]; then
                rm -f "$copies"
                die "account $(short_uid "$value") is not present in any slot or logged project.
Log it into a slot first (e.g. kimi-<suffix> login), then retry."
            fi
        fi
    fi

    uid=$(printf '%s' "$source" | cut -f1)
    iat=$(printf '%s' "$source" | cut -f2)
    exp=$(printf '%s' "$source" | cut -f3)
    cred_file=$(printf '%s' "$source" | cut -f4)
    source_home=$(dirname "$(dirname "$cred_file")")
    [ "$source_home" = "$home" ] \
        && die "source and target are the same home ($home); nothing to deploy"

    if project_has_home "$home"; then
        replace_home_auth "$home"
    fi

    mkdir -p "$home"
    cp -p "$source_home/config.toml" "$home/config.toml"
    chmod 600 "$home/config.toml"
    mkdir -p "$home/credentials"
    chmod 700 "$home/credentials"
    cp -a "$source_home/credentials/." "$home/credentials/"
    find "$home/credentials" -type f -exec chmod 600 {} +

    append_log deploy "selector=$sel" "user_id=$uid" "source_home=$source_home" \
        "home=$home" "cred_iat=$iat"
    rm -f "$copies"

    local aliases
    aliases=$(aliases_for_uid "$uid")
    [ -n "$aliases" ] && aliases=" ($aliases)"
    printf 'deployed %s%s from %s\n' "$(short_uid "$uid")" "$aliases" "$source_home"
    printf '  credential refreshed %s ago; refresh TTL %s\n' "$(fmt_age $((now - iat)))" "$(fmt_age $((exp - now)))"
    printf '  into %s\n' "$home"
    if [ -z "$via_env" ]; then
        printf 'next: export KIMI_CODE_HOME=%s\n' "$home"
        printf '      (or from its project dir: source ~/set-kimi-home-as-pwd.sh)\n'
    fi
}

cmd_backup() { # [--project DIR] — copy the target home's auth into <home>/.backup/
    local home current uid
    home=$(target_home)
    is_excluded_home "$home" \
        && die "$home is excluded (private); backup would read its credentials. Run 'include <slot>' to lift this."
    project_has_home "$home" || die "$home has no config.toml or credentials/ — nothing to back up"

    current=$(slot_current "$home" || true)
    uid=
    if [ -n "$current" ]; then
        uid=$(printf '%s' "$current" | cut -f1)
    fi

    backup_home "$home"
    append_log backup "user_id=$uid" "home=$home"
    printf 'backed up %s\n' "$home"
    printf '  into %s (single backup entry per home)\n' "$home/.backup"
    if [ -n "$uid" ]; then
        printf '  account: %s\n' "$(short_uid "$uid")"
    fi
    printf '  undo with: kimi-project.sh restore   (same target resolution as backup)\n'
}

cmd_restore() { # [--project DIR] — overwrite the target home's auth with its .backup/
    local home current uid had_live
    home=$(target_home)
    is_excluded_home "$home" \
        && die "$home is excluded (private); restore would touch its credentials. Run 'include <slot>' to lift this."
    [ -d "$home/.backup" ] || die "no backup at $home/.backup — nothing to restore"
    if [ ! -e "$home/.backup/config.toml" ] && [ ! -d "$home/.backup/credentials" ]; then
        die "backup at $home/.backup holds neither config.toml nor credentials/"
    fi

    had_live=
    if project_has_home "$home"; then
        had_live=1
    fi
    rm -f "$home/config.toml"
    rm -rf "$home/credentials"
    if [ -e "$home/.backup/config.toml" ]; then
        cp -p "$home/.backup/config.toml" "$home/config.toml"
        chmod 600 "$home/config.toml"
    fi
    if [ -d "$home/.backup/credentials" ]; then
        mkdir -p "$home/credentials"
        chmod 700 "$home/credentials"
        cp -a "$home/.backup/credentials/." "$home/credentials/"
        find "$home/credentials" -type f -exec chmod 600 {} +
    fi

    current=$(slot_current "$home" || true)
    uid=
    if [ -n "$current" ]; then
        uid=$(printf '%s' "$current" | cut -f1)
    fi
    append_log restore "user_id=$uid" "home=$home"
    printf 'restored %s from %s\n' "$home" "$home/.backup"
    if [ -n "$uid" ]; then
        printf '  account: %s\n' "$(short_uid "$uid")"
    fi
    if [ -n "$had_live" ]; then
        printf '  the previous live auth was overwritten\n'
    fi
    printf '  backup kept at %s (restores are repeatable)\n' "$home/.backup"
}

cmd_forget() { # [--dead | PATH ...] — drop deployment-record entries; homes are the caller's concern
    [ -f "$LOG_FILE" ] || { printf 'deployment log is empty\n'; return 0; }
    local tmp removed=0 line h p hh keep x cand
    local -a cand_home=() cand_proj=()
    if [ "$OPT_DEAD" != 1 ]; then
        [ $# -ge 1 ] || die "forget needs at least one PATH, or --dead"
        for x in "$@"; do
            x=${x%/}
            if [ -d "$x" ]; then
                x=$(cd "$x" && pwd -P)
            fi
            cand_home+=("$x" "$x/.kimi-code")
            cand_proj+=("$x")
            case $x in
                */.kimi-code) cand_proj+=("$(dirname "$x")") ;;
            esac
        done
    fi
    tmp=$(mktemp)
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        h=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
        [ "$h" = "null" ] && h=
        p=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
        [ "$p" = "null" ] && p=
        keep=1
        if [ "$OPT_DEAD" = 1 ]; then
            hh=$h
            if [ -z "$hh" ] && [ -n "$p" ]; then hh="$p/.kimi-code"; fi
            if [ -n "$hh" ] && [ ! -e "$hh" ]; then
                keep=0
            fi
        else
            for cand in "${cand_home[@]}"; do
                if [ -n "$h" ] && [ "$h" = "$cand" ]; then
                    keep=0
                    break
                fi
            done
            if [ "$keep" = 1 ]; then
                for cand in "${cand_proj[@]}"; do
                    if [ -n "$p" ] && [ "$p" = "$cand" ]; then
                        keep=0
                        break
                    fi
                done
            fi
        fi
        if [ "$keep" = 0 ]; then
            removed=$((removed + 1))
            printf '  dropping: %s\n' "$(fmt_log_line "$line")"
        else
            printf '%s\n' "$line" >> "$tmp"
        fi
    done < "$LOG_FILE"
    if [ "$removed" -eq 0 ]; then
        rm -f "$tmp"
        printf 'no matching log entries\n'
        return 0
    fi
    chmod 600 "$tmp"
    mv "$tmp" "$LOG_FILE"
    if [ "$removed" -eq 1 ]; then
        printf 'forgot 1 log entry\n'
    else
        printf 'forgot %d log entries\n' "$removed"
    fi
    if [ "$OPT_DEAD" != 1 ]; then
        for x in "$@"; do
            x=${x%/}
            if [ -d "$x" ]; then
                x=$(cd "$x" && pwd -P)
            fi
            hh=
            if [ -e "$x/.kimi-code" ]; then
                hh="$x/.kimi-code"
            elif [ "${x##*/}" = .kimi-code ]; then
                hh="$x"
            fi
            if [ -n "$hh" ] && project_has_home "$hh"; then
                printf 'note: %s still holds credentials; scan no longer tracks it\n' "$hh"
            fi
        done
    fi
}

# ---------------------------------------------------------------------------
# Entrypoint

usage() {
    cat >&2 <<'EOF'
Usage: kimi-project.sh <command> [args]

Read-only:
  list                          show slots, aliases, and drift state
  status [--project DIR]        show a project's account state (default: cwd)
  log [COUNT]                   show deployment log (default 20 entries)
  scan [PATH ...]               freshness + drift audit over slots and logged projects;
                                extra PATHs may be homes, projects, or parents of projects

Mutating:
  deploy <selector> [opts]      copy an account's config+credentials into the target home
                                selector: alias, slot name, or account-id prefix
                                target: --project DIR, else $KIMI_CODE_HOME, else cwd's .kimi-code;
                                missing or empty targets are created/filled without flags
                                opts: --from SLOT  --project DIR
                                      --force              overwrite an occupied home (no backup)
                                      --force-with-backup  back the home up to .backup/ first
  backup [--project DIR]        copy the target home's config+credentials into its .backup/
                                (single entry; overwrites the previous backup). Target home:
                                --project DIR, else $KIMI_CODE_HOME, else ~/.kimi-code
  restore [--project DIR]       overwrite the target home's config+credentials with the
                                contents of its .backup/ (same target resolution as backup)
  forget [--dead | PATH ...]    drop deployment-record entries: entries matching PATHs
                                (a home or its project dir), or with --dead every entry
                                whose home no longer exists. Homes themselves are the
                                caller's concern — forget never removes files
  register <slot> <auth.json>   declare the account a slot is expected to hold; the
                                account id is read from the given credential file,
                                never inferred from the slot's current contents
  alias <name> <slot> [--force] bind an alias to the account currently in a slot
  unalias <name>                remove an alias
  exclude <slot>                mark a slot private: never read, scanned, or deployed from
  include <slot>                lift the exclusion
EOF
}

OPT_PROJECT=; OPT_FROM=; OPT_FORCE=0; OPT_FORCE_BACKUP=0; OPT_DEAD=0
cmd=${1:-}
[ $# -gt 0 ] && shift || { usage; exit 2; }

pos=()
while [ $# -gt 0 ]; do
    case $1 in
        --project) OPT_PROJECT=${2:?--project requires a value}; shift 2 ;;
        --from) OPT_FROM=${2:?--from requires a value}; shift 2 ;;
        --force) OPT_FORCE=1; shift ;;
        --force-with-backup) OPT_FORCE_BACKUP=1; OPT_FORCE=1; shift ;;
        --dead) OPT_DEAD=1; shift ;;
        -h | --help) usage; exit 0 ;;
        --) shift; while [ $# -gt 0 ]; do pos+=("$1"); shift; done ;;
        *) pos+=("$1"); shift ;;
    esac
done
[ ${#pos[@]} -gt 0 ] && set -- "${pos[@]}" || set --

case $cmd in
    list) cmd_list ;;
    status) cmd_status ;;
    log) cmd_log "${1:-20}" ;;
    scan) cmd_scan "$@" ;;
    register) [ $# -eq 2 ] || { usage; exit 2; }; cmd_register "$1" "$2" ;;
    alias) [ $# -ge 2 ] || { usage; exit 2; }; cmd_alias "$1" "$2" ;;
    unalias) [ $# -eq 1 ] || { usage; exit 2; }; cmd_unalias "$1" ;;
    exclude) [ $# -eq 1 ] || { usage; exit 2; }; cmd_exclude "$1" ;;
    include) [ $# -eq 1 ] || { usage; exit 2; }; cmd_include "$1" ;;
    deploy) [ $# -ge 1 ] || { usage; exit 2; }; cmd_deploy "$1" ;;
    backup) cmd_backup ;;
    restore) cmd_restore ;;
    forget) cmd_forget "$@" ;;
    -h | --help | help) usage ;;
    *) usage; exit 2 ;;
esac
