#!/usr/bin/env bash
# kimi-project.sh — deploy and track Kimi Code auth sessions in project-scope
# data homes.
#
# An "auth session" is one independent OAuth login, identified by
# (user_id, device_id) read from the refresh-token JWT: the device_id claim is
# stable per login grant and survives refreshes, while independent logins of
# the same account carry different device ids. Several sessions of one account
# are distinct, separately deployable units; copies of the SAME session (a
# slot home plus every project it was deployed into) are linked: they refresh
# independently, the freshest copy is tracked per session, and a newer copy is
# rescued back into the session's registered slot home(s) so the session can
# always be returned home (also on undeploy).
#
# Account "slots" are the long-lived Kimi data homes: ~/.kimi-code (slot
# "default") plus every directory under ~/kimi-homes/ (one per kimi-<suffix>
# launcher). A slot registered to a session is that session's canonical home.
# This tool copies a session's auth state (config.toml + credentials/) into a
# project's .kimi-code/ home, tracks which session each slot is expected to
# hold, detects slots re-logged into a different account OR a different login
# of the same account (a new device_id is drift), and logs every deployment so
# later audits know where credentials live.
#
# Runtime state: ~/kimi-homes/manifest.json (all configurable state: session
# aliases, per-slot expected session + exclusion flag, and a sessions cache
# recording each session's last-known freshest copy location),
# ~/kimi-homes/deployments.jsonl (append-only deployment log), and per-home
# .backup/ directories: single-entry auth backups written by backup or by
# deploy/undeploy --force-with-backup, read by restore. No token material is
# ever written to state files or printed. A slot whose "flags" is "excluded"
# is private: its credentials are never read, scanned, or deployed by any
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

# --- manifest.json access (all configurable state lives here, v2 schema) ----
# Leaf lines from JSON.awk look like: ["aliases","main"]\t"dalvfs...:d125..."
# or ["slots","default","path"]\t"/home/...". Values read here are account
# ids, device ids, slot/alias names, and paths — quote/backslash escapes are
# not expected and are not decoded.

man_read() { # dump manifest leaf lines; empty when no manifest exists
    [ -f "$MANIFEST" ] || return 0
    awk -f "$JSONAWK_FILE" "$MANIFEST" 2>/dev/null
}

man_version() { # -> manifest schema version, empty when no manifest
    [ -f "$MANIFEST" ] || return 0
    ajq "$MANIFEST" version 2>/dev/null || true
}

man_aliases() { # -> "name\tsession_key" lines (legacy values may be uid-only)
    man_read | awk -F'\t' '$1 ~ /^\["aliases","[^"]+"\]$/ {
        name = $1
        sub(/^\["aliases","/, "", name); sub(/"\]$/, "", name)
        v = substr($0, index($0, "\t") + 1)
        gsub(/^"|"$/, "", v)
        print name "\t" v
    }'
}

man_alias_get() { # NAME -> session key (or legacy uid), empty when unbound
    man_aliases | awk -F'\t' -v k="$1" '$1 == k && !f { print $2; f = 1 }'
}

man_slots() { # -> "slot\tpath\texpected_uid\texpected_device\tflags\tupdated_at" lines
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
            printf "%s\t%s\t%s\t%s\t%s\t%s\n", s, vals[s,"path"], vals[s,"expected_user_id"], vals[s,"expected_device_id"], vals[s,"flags"], vals[s,"updated_at"]
    }'
}

man_slot_field() { # SLOT FIELD -> value, empty when unset
    man_read | awk -F'\t' -v k='["slots","'"$1"'","'"$2"'"]' \
        '$1 == k && !f { v = substr($0, index($0, "\t") + 1); gsub(/^"|"$/, "", v); print v; f = 1 }'
}

slot_flags() { man_slot_field "$1" flags; }
slot_expected() { man_slot_field "$1" expected_user_id; }
slot_expected_device() { man_slot_field "$1" expected_device_id; }

is_excluded() { # SLOT -> rc 0 when the slot is flagged excluded (private)
    [ "$(slot_flags "$1")" = "excluded" ]
}

excluded_homes() { # home paths of excluded slots
    man_slots | awk -F'\t' '$5 == "excluded" { print $2 }'
}

is_excluded_home() { # PATH -> rc 0 when PATH is an excluded slot's home
    excluded_homes | grep -x -F -- "$1" >/dev/null
}

man_sessions() { # -> "key\tfreshest_home\tfreshest_iat\tupdated_at" lines (sessions cache)
    man_read | awk -F'\t' '$1 ~ /^\["sessions","[^"]+","[^"]+"\]$/ {
        line = $1
        sub(/^\["sessions","/, "", line); sub(/"\]$/, "", line)
        split(line, parts, "\",\"")
        key = parts[1]; field = parts[2]
        v = substr($0, index($0, "\t") + 1)
        gsub(/^"|"$/, "", v)
        seen[key] = 1
        vals[key, field] = v
    }
    END {
        for (s in seen)
            printf "%s\t%s\t%s\t%s\n", s, vals[s,"freshest_home"], vals[s,"freshest_iat"], vals[s,"updated_at"]
    }'
}

man_session_field() { # KEY FIELD -> value, empty when unset
    man_read | awk -F'\t' -v k='["sessions","'"$1"'","'"$2"'"]' \
        '$1 == k && !f { v = substr($0, index($0, "\t") + 1); gsub(/^"|"$/, "", v); print v; f = 1 }'
}

manifest_write() { # ALIASES_FILE SLOTS_FILE SESSIONS_FILE — atomically regenerate manifest.json
    # Slot lines: "slot\tpath\texpected_uid\texpected_device\tflags\tupdated_at".
    # Session lines: "key\tfreshest_home\tfreshest_iat\tupdated_at".
    # Flags may be empty, so fields are parsed with awk (read with IFS=tab
    # would collapse consecutive tabs and shift the columns).
    mkdir -p "$HOMES_ROOT"
    local tmp
    tmp=$(mktemp)
    awk -F'\t' '
        function jesc(s) { gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s); return s }
        function num(s) { return (s ~ /^[0-9]+$/) ? s : 0 }
        FILENAME == ARGV[1] {
            if ($1 != "") { na++; an[na] = $1; av[na] = $2 }
            next
        }
        FILENAME == ARGV[2] {
            if ($1 != "") { ns++; sn[ns] = $1; sp[ns] = $2; se[ns] = $3; sd[ns] = $4; sf[ns] = $5; su[ns] = $6 }
            next
        }
        $1 != "" { nx++; xk[nx] = $1; xh[nx] = $2; xi[nx] = $3; xu[nx] = $4 }
        END {
            print "{"
            print "  \"version\": 2,"
            if (na == 0) {
                print "  \"aliases\": {},"
            } else {
                print "  \"aliases\": {"
                for (i = 1; i <= na; i++)
                    printf "    \"%s\": \"%s\"%s\n", jesc(an[i]), jesc(av[i]), (i < na ? "," : "")
                print "  },"
            }
            if (ns == 0) {
                print "  \"slots\": {},"
            } else {
                print "  \"slots\": {"
                for (i = 1; i <= ns; i++) {
                    printf "    \"%s\": {\n", jesc(sn[i])
                    printf "      \"path\": \"%s\",\n", jesc(sp[i])
                    printf "      \"expected_user_id\": \"%s\",\n", jesc(se[i])
                    printf "      \"expected_device_id\": \"%s\",\n", jesc(sd[i])
                    printf "      \"flags\": \"%s\",\n", jesc(sf[i])
                    printf "      \"updated_at\": \"%s\"\n", jesc(su[i])
                    printf "    }%s\n", (i < ns ? "," : "")
                }
                print "  },"
            }
            if (nx == 0) {
                print "  \"sessions\": {}"
            } else {
                print "  \"sessions\": {"
                for (i = 1; i <= nx; i++) {
                    split(xk[i], kp, ":")
                    printf "    \"%s\": {\n", jesc(xk[i])
                    printf "      \"user_id\": \"%s\",\n", jesc(kp[1])
                    printf "      \"device_id\": \"%s\",\n", jesc(kp[2])
                    printf "      \"freshest_home\": \"%s\",\n", jesc(xh[i])
                    printf "      \"freshest_iat\": %s,\n", num(xi[i])
                    printf "      \"updated_at\": \"%s\"\n", jesc(xu[i])
                    printf "    }%s\n", (i < nx ? "," : "")
                }
                print "  }"
            }
            print "}"
        }
    ' "$1" "$2" "$3" > "$tmp"
    chmod 600 "$tmp"
    mv "$tmp" "$MANIFEST"
}

man_alias_set() { # NAME KEY — bind, or delete when KEY is empty
    local name=$1 key=$2 tmpa tmps tmpx
    tmpa=$(mktemp); tmps=$(mktemp); tmpx=$(mktemp)
    man_aliases | awk -F'\t' -v k="$name" '$1 != k' > "$tmpa"
    [ -n "$key" ] && printf '%s\t%s\n' "$name" "$key" >> "$tmpa"
    man_slots > "$tmps"
    man_sessions > "$tmpx"
    manifest_write "$tmpa" "$tmps" "$tmpx"
    rm -f "$tmpa" "$tmps" "$tmpx"
}

man_slot_set() { # SLOT PATH EXPECTED_UID EXPECTED_DEVICE FLAGS — replace/insert a slot entry
    local slot=$1 path=$2 expected=$3 expected_dev=$4 flags=$5 tmpa tmps tmpx
    tmpa=$(mktemp); tmps=$(mktemp); tmpx=$(mktemp)
    man_aliases > "$tmpa"
    man_slots | awk -F'\t' -v k="$slot" '$1 != k' > "$tmps"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$slot" "$path" "$expected" "$expected_dev" "$flags" "$(date +%Y-%m-%dT%H:%M:%S)" >> "$tmps"
    man_sessions > "$tmpx"
    manifest_write "$tmpa" "$tmps" "$tmpx"
    rm -f "$tmpa" "$tmps" "$tmpx"
}

man_session_note() { # KEY HOME IAT — record freshest-known location when newer (sessions cache)
    local key=$1 home=$2 iat=$3 existing tmpa tmps tmpx
    [ -n "$key" ] && [ -n "$iat" ] || return 0
    existing=$(man_session_field "$key" freshest_iat)
    case $existing in '' | *[!0-9]*) existing=0 ;; esac
    [ "$existing" -ge "$iat" ] && return 0
    tmpa=$(mktemp); tmps=$(mktemp); tmpx=$(mktemp)
    man_aliases > "$tmpa"
    man_slots > "$tmps"
    man_sessions | awk -F'\t' -v k="$key" '$1 != k' > "$tmpx"
    printf '%s\t%s\t%s\t%s\n' "$key" "$home" "$iat" "$(date +%Y-%m-%dT%H:%M:%S)" >> "$tmpx"
    manifest_write "$tmpa" "$tmps" "$tmpx"
    rm -f "$tmpa" "$tmps" "$tmpx"
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

short_sess() { # UID DEVICE -> shortuid/shortdev (shortuid/? when device unknown)
    local u=$1 d=$2
    if [ -n "$d" ] && [ "$d" != "unknown" ]; then
        printf '%s/%s' "${u:0:8}" "${d:0:8}"
    else
        printf '%s/?' "${u:0:8}"
    fi
}

short_key() { # SESSION_KEY -> short form; tolerates legacy uid-only keys
    case $1 in
        *:*) short_sess "${1%%:*}" "${1#*:}" ;;
        *) short_uid "$1" ;;
    esac
}

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

cred_info() { # CRED_FILE -> "user_id\tiat\texp\tdevice_id"; rc 1 when unreadable
    local f=$1 tok payload uid iat exp dev
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
    dev=$(printf '%s' "$payload" | ajq - device_id -s 2>/dev/null || true)
    [ "$dev" = "null" ] && dev=
    printf '%s\t%s\t%s\t%s\n' "$uid" "$iat" "$exp" "$dev"
}

home_creds() { # HOME -> lines "user_id\tiat\trefresh_exp\tdevice_id\tcred_file"
    local home=$1 f info dev
    [ -d "$home/credentials" ] || return 0
    for f in "$home/credentials"/*.json; do
        [ -e "$f" ] || continue
        if info=$(cred_info "$f"); then
            dev=$(printf '%s' "$info" | cut -f4)
            if [ -z "$dev" ] && [ -f "$home/device_id" ]; then
                dev=$(head -c 64 "$home/device_id" 2>/dev/null | tr -d '[:space:]')
                [ -n "$dev" ] && info=$(printf '%s\t%s\t%s\t%s' \
                    "$(printf '%s' "$info" | cut -f1)" \
                    "$(printf '%s' "$info" | cut -f2)" \
                    "$(printf '%s' "$info" | cut -f3)" "$dev")
            fi
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

deploy_home() { # deploy/undeploy target: --project DIR > $KIMI_CODE_HOME > cwd/.kimi-code
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

log_entry_home() { # LINE -> deploy-target home path (handles legacy project= entries)
    local line=$1 home proj
    home=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
    if [ -n "$home" ] && [ "$home" != "null" ]; then
        printf '%s\n' "$home"
        return 0
    fi
    proj=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
    if [ -n "$proj" ] && [ "$proj" != "null" ]; then
        printf '%s/.kimi-code\n' "$proj"
    fi
}

log_entry_device() { # LINE -> device_id field, empty when absent (legacy entries)
    local line=$1 dev
    dev=$(printf '%s' "$line" | ajq - device_id -s 2>/dev/null || true)
    [ "$dev" = "null" ] && dev=
    printf '%s' "$dev"
}

last_deploy_for_session() { # UID DEVICE -> newest deploy log line for the session
    # Legacy entries without device_id match any session of their account.
    [ -f "$LOG_FILE" ] || return 0
    local line action uid dev
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        action=$(printf '%s' "$line" | ajq - action -s 2>/dev/null || true)
        [ "$action" = "deploy" ] || continue
        uid=$(printf '%s' "$line" | ajq - user_id -s 2>/dev/null || true)
        [ "$uid" = "$1" ] || continue
        dev=$(log_entry_device "$line")
        if [ -z "$dev" ] || [ "$dev" = "$2" ]; then
            printf '%s\n' "$line"
        fi
    done < "$LOG_FILE" | tail -n 1
}

aliases_for_uid() { # USER_ID -> comma-joined alias names (matches uid and uid:device values)
    man_aliases | awk -F'\t' -v uid="$1" '{ v = $2; sub(/:.*/, "", v) } v == uid { print $1 }' \
        | sort | paste -sd, -
}

aliases_legacy_for_uid() { # USER_ID -> comma-joined names of legacy (uid-only) aliases only
    man_aliases | awk -F'\t' -v uid="$1" '$2 !~ /:/ && $2 == uid { print $1 }' \
        | sort | paste -sd, -
}

aliases_for_session() { # UID DEVICE -> comma-joined alias names bound to exactly this session
    man_aliases | awk -F'\t' -v k="$1:$2" '$2 == k { print $1 }' | sort | paste -sd, -
}

slot_state() { # SLOT CURRENT_LINE -> state text
    local slot=$1 current=$2 expected expected_dev path updated
    is_excluded "$slot" && { printf 'excluded (private)'; return 0; }
    [ -n "$current" ] || { printf 'empty'; return 0; }
    expected=$(slot_expected "$slot")
    if [ -z "$expected" ]; then
        printf 'untracked (register with: register %s AUTH_JSON)' "$slot"
        return 0
    fi
    local uid dev
    uid=$(printf '%s' "$current" | cut -f1)
    dev=$(printf '%s' "$current" | cut -f4)
    if [ "$expected" != "$uid" ]; then
        local al
        al=$(aliases_for_uid "$expected")
        [ -n "$al" ] && al=" ($al)"
        printf 'DRIFTED — expected account %s%s, holds %s' "$(short_uid "$expected")" "$al" "$(short_uid "$uid")"
        return 0
    fi
    expected_dev=$(slot_expected_device "$slot")
    if [ -n "$expected_dev" ] && [ -n "$dev" ] && [ "$expected_dev" != "$dev" ]; then
        printf 'DRIFTED — same account, different login session: expected %s, holds %s' \
            "$(short_sess "$expected" "$expected_dev")" "$(short_sess "$uid" "$dev")"
        return 0
    fi
    printf 'ok'
}

freshest_for_session() { # COPIES_TSV_FILE USER_ID DEVICE -> freshest line, empty when none
    awk -F'\t' -v uid="$2" -v dev="$3" \
        '$1 == uid && $4 == dev { if (max == "" || $2+0 > max) { max = $2+0; line = $0 } }
         END { if (line != "") print line }' "$1"
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

# --- manifest v1 -> v2 migration ---------------------------------------------

ensure_manifest_v2() { # no-op unless a legacy manifest needs migration
    [ -f "$MANIFEST" ] || return 0
    [ "$(man_version)" = "2" ] && return 0
    printf 'migrating manifest to v2 (session-based identity)...\n'
    local copies tmpa tmps tmpx
    copies=$(mktemp); tmpa=$(mktemp); tmps=$(mktemp); tmpx=$(mktemp)
    collect_copies > "$copies"

    # Slots: drop entries whose home vanished; fill expected_device_id from the
    # slot's live credential when it still holds the expected account.
    local line slot path euid edev flags updated cur
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        slot=$(printf '%s' "$line" | cut -f1)
        path=$(printf '%s' "$line" | cut -f2)
        euid=$(printf '%s' "$line" | cut -f3)
        edev=$(printf '%s' "$line" | cut -f4)
        flags=$(printf '%s' "$line" | cut -f5)
        updated=$(printf '%s' "$line" | cut -f6)
        if [ ! -d "$path" ]; then
            printf '  dropped slot %s: home no longer exists (%s)\n' "$slot" "$path"
            continue
        fi
        if [ -n "$euid" ] && [ -z "$edev" ]; then
            cur=$(slot_current "$path" || true)
            if [ -n "$cur" ] && [ "$(printf '%s' "$cur" | cut -f1)" = "$euid" ]; then
                edev=$(printf '%s' "$cur" | cut -f4)
            fi
        fi
        printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$slot" "$path" "$euid" "$edev" "$flags" "$updated" >> "$tmps"
    done < <(man_slots)

    # Aliases: rebind uid-only values to a concrete session. Prefer the session
    # held by a registered slot of that account; else the only live session;
    # else leave uid-only (still resolvable) and warn.
    local name value seats key cand n_cand
    while IFS=$'\t' read -r name value; do
        [ -n "$name" ] || continue
        case $value in *:*)
            printf '%s\t%s\n' "$name" "$value" >> "$tmpa"
            continue ;;
        esac
        key=
        seats=$(awk -F'\t' -v uid="$value" '$3 == uid && $4 != "" { print $3 ":" $4 }' "$tmps" | sort -u)
        if [ "$(printf '%s\n' "$seats" | grep -c .)" -eq 1 ]; then
            key=$seats
        else
            cand=$(awk -F'\t' -v uid="$value" '$1 == uid { print $1 ":" $4 }' "$copies" | sort -u)
            n_cand=$(printf '%s\n' "$cand" | grep -c . || true)
            if [ "$n_cand" -eq 1 ]; then
                key=$cand
            fi
        fi
        if [ -n "$key" ]; then
            printf '  alias %s: bound to session %s\n' "$name" "$(short_key "$key")"
            printf '%s\t%s\n' "$name" "$key" >> "$tmpa"
        else
            printf '  warning: alias %s left bound to account %s — multiple live sessions;\n' \
                "$name" "$(short_uid "$value")" >&2
            printf '           rebind to a session with: alias %s <slot>\n' "$name" >&2
            printf '%s\t%s\n' "$name" "$value" >> "$tmpa"
        fi
    done < <(man_aliases)

    # Sessions cache: seed from the live copies.
    awk -F'\t' '{ k = $1 ":" $4
        if (!(k in max) || $2+0 > max[k]) { max[k] = $2+0; home[k] = $5 } }
        END { for (k in max) printf "%s\t%s\t%s\t%s\n", k, home[k], max[k], "'"$(date +%Y-%m-%dT%H:%M:%S)"'" }' \
        "$copies" > "$tmpx"

    manifest_write "$tmpa" "$tmps" "$tmpx"
    rm -f "$copies" "$tmpa" "$tmps" "$tmpx"
    printf 'manifest migrated to v2\n'
}

# ---------------------------------------------------------------------------
# Read-only commands

slot_whereabouts() { # COPIES_FILE NOW HOME UID DEVICE SLOT_IAT — per-slot last-deploy + freshest-auth line
    local copies=$1 now=$2 home=$3 uid=$4 dev=$5 slot_iat=$6 last lhome lts best bhome biat
    last=$(last_deploy_for_session "$uid" "$dev" || true)
    printf '      '
    if [ -n "$last" ]; then
        lhome=$(log_entry_home "$last" || true)
        lts=$(printf '%s' "$last" | ajq - ts 2>/dev/null || true)
        case $lts in '' | *[!0-9]*) lts=0 ;; esac
        printf 'last deployed: %s (%s ago)' "${lhome:-unknown}" "$(fmt_age $((now - lts)))"
    else
        printf 'last deployed: never'
    fi
    best=$(freshest_for_session "$copies" "$uid" "$dev" || true)
    if [ -n "$best" ]; then
        bhome=$(dirname "$(dirname "$(printf '%s' "$best" | cut -f5)")")
        biat=$(printf '%s' "$best" | cut -f2)
        if [ "$bhome" = "$home" ] || { [ -n "$slot_iat" ] && [ "$biat" = "$slot_iat" ]; }; then
            printf '; freshest auth: this slot\n'
        else
            printf '; freshest auth: %s (%s ago)\n' "$bhome" "$(fmt_age $((now - biat)))"
        fi
    else
        printf '; freshest auth: none found\n'
    fi
}

cmd_list() {
    local now name home current uid dev aliases refreshed ttl state
    now=$(date +%s)
    local copies
    copies=$(mktemp)
    collect_copies > "$copies"
    printf 'slots:\n'
    printf '  %-14s %-10s %-19s %-10s %-7s state\n' name alias session refreshed TTL
    discover_slots | while IFS=$'\t' read -r name home; do
        if is_excluded "$name"; then
            printf '  %-14s %-10s %-19s %-10s %-7s %s\n' \
                "$name" - - - - "excluded (private) — credentials not read"
            continue
        fi
        current=$(slot_current "$home" || true)
        if [ -n "$current" ]; then
            uid=$(printf '%s' "$current" | cut -f1)
            dev=$(printf '%s' "$current" | cut -f4)
            aliases=$(aliases_for_session "$uid" "$dev")
            [ -n "$aliases" ] || aliases=$(aliases_legacy_for_uid "$uid")
            aliases=${aliases:--}
            refreshed="$(fmt_age $((now - $(printf '%s' "$current" | cut -f2)))) ago"
            ttl=$(fmt_age $(( $(printf '%s' "$current" | cut -f3) - now )))
        else
            uid=$(slot_expected "$name"); dev=$(slot_expected_device "$name")
            aliases=-; refreshed=-; ttl=-
        fi
        state=$(slot_state "$name" "$current")
        printf '  %-14s %-10s %-19s %-10s %-7s %s\n' \
            "$name" "$aliases" "$(short_sess "${uid:--}" "$dev")" "$refreshed" "$ttl" "$state"
        if [ -n "$uid" ] && [ -n "$current" ]; then
            slot_whereabouts "$copies" "$now" "$home" "$uid" "$dev" "$(printf '%s' "$current" | cut -f2)"
        fi
    done

    [ -f "$MANIFEST" ] || { rm -f "$copies"; return 0; }
    printf '\naliases:\n'
    man_aliases | while IFS=$'\t' read -r name key; do
        [ -n "$name" ] || continue
        local uid dev best legacy
        legacy=
        case $key in
            *:*) uid=${key%%:*}; dev=${key#*:} ;;
            *) uid=$key; dev=; legacy=" (account alias — rebind with: alias $name <slot>)" ;;
        esac
        if [ -n "$dev" ]; then
            best=$(freshest_for_session "$copies" "$uid" "$dev" || true)
        else
            best=$(awk -F'\t' -v uid="$uid" \
                '$1 == uid { if (max == "" || $2+0 > max) { max = $2+0; line = $0 } }
                 END { if (line != "") print line }' "$copies")
        fi
        if [ -n "$best" ]; then
            local best_home iat
            iat=$(printf '%s' "$best" | cut -f2)
            best_home=$(dirname "$(dirname "$(printf '%s' "$best" | cut -f5)")")
            printf '  %-10s %-19s freshest: %s (%s ago)%s\n' \
                "$name" "$(short_key "$key")" "$best_home" "$(fmt_age $((now - iat)))" "$legacy"
            if [ -n "$dev" ]; then
                awk -F'\t' -v uid="$uid" -v dev="$dev" '$1 == uid && $4 == dev { print $5 }' "$copies"
            else
                awk -F'\t' -v uid="$uid" '$1 == uid { print $5 }' "$copies"
            fi | sort -u | while IFS= read -r f; do
                printf '  %-10s %-19s copy:     %s\n' '' '' "$(dirname "$(dirname "$f")")"
            done
        else
            if man_slots | awk -F'\t' -v uid="$uid" '$5 == "excluded" && $3 == uid { found = 1 } END { exit !found }'; then
                printf '  %-10s %-19s private — held only by an excluded slot, unavailable for deploy\n' \
                    "$name" "$(short_key "$key")"
            else
                printf '  %-10s %-19s MISSING — no slot or logged project holds this session%s\n' \
                    "$name" "$(short_key "$key")" "$legacy"
            fi
        fi
    done

    local first=1 skey shome siat supdated seats
    if [ -s "$MANIFEST" ] && man_sessions | grep -q .; then
        printf '\nsessions (tracked freshest per login):\n'
        while IFS=$'\t' read -r skey shome siat supdated; do
            [ -n "$skey" ] || continue
            first=0
            seats=$(man_slots | awk -F'\t' -v k="$skey" '{ ks = $3; if ($4 != "") ks = $3 ":" $4 }
                ks == k { print $1 }' | sort | paste -sd, -)
            case $siat in '' | *[!0-9]*) siat=0 ;; esac
            printf '  %-19s seats: %-24s tracked freshest: %s (%s ago)\n' \
                "$(short_key "$skey")" "${seats:--}" "${shome:-unknown}" "$(fmt_age $((now - siat)))"
        done < <(man_sessions)
    fi
    rm -f "$copies"
}

cmd_status() { # [--project DIR]
    local project home now current uid dev iat exp aliases
    project=$(project_dir)
    home="$project/.kimi-code"
    now=$(date +%s)

    if ! project_has_home "$home"; then
        printf '%s: no project home (deploy to create one)\n' "$project"
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
    dev=$(printf '%s' "$current" | cut -f4)
    aliases=$(aliases_for_session "$uid" "$dev")
    [ -n "$aliases" ] && aliases=" ($aliases)"
    printf '  session: %s%s\n' "$(short_sess "$uid" "$dev")" "$aliases"
    printf '  refreshed: %s ago; refresh token TTL %s\n' "$(fmt_age $((now - iat)))" "$(fmt_age $((exp - now)))"

    local last deployed_uid deployed_dev
    last=$(last_deploy_entry "$home")
    if [ -n "$last" ]; then
        printf '  last deployed: %s from %s\n' \
            "$(printf '%s' "$last" | ajq - time -s)" "$(printf '%s' "$last" | ajq - source_home -s)"
        deployed_uid=$(printf '%s' "$last" | ajq - user_id -s)
        deployed_dev=$(log_entry_device "$last")
        if [ -n "$deployed_uid" ] && { [ "$deployed_uid" != "$uid" ] || { [ -n "$deployed_dev" ] && [ "$deployed_dev" != "$dev" ]; }; }; then
            printf '  DRIFTED — deployed as %s, now holds %s\n' \
                "$(short_sess "$deployed_uid" "$deployed_dev")" "$(short_sess "$uid" "$dev")"
        fi
    else
        printf '  last deployed: never (no log entry for this project)\n'
    fi

    local copies best cred_file
    copies=$(mktemp); collect_copies > "$copies"
    best=$(freshest_for_session "$copies" "$uid" "$dev" || true)
    cred_file=$(printf '%s' "$current" | cut -f5)
    if [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f5)" != "$cred_file" ] \
        && [ "$(printf '%s' "$best" | cut -f2)" -gt "$iat" ]; then
        printf '  stale — a fresher copy of this session exists at %s (newer by %s)\n' \
            "$(dirname "$(dirname "$(printf '%s' "$best" | cut -f5)")")" \
            "$(fmt_age $(( $(printf '%s' "$best" | cut -f2) - iat )))"
    else
        printf '  this copy is the freshest known for its session\n'
    fi
    rm -f "$copies"
}

fmt_log_line() { # LINE -> compact rendering of a deployment-log entry
    local line=$1 time_s action uid dev project source backup home out
    time_s=$(printf '%s' "$line" | ajq - time -s)
    action=$(printf '%s' "$line" | ajq - action -s)
    uid=$(printf '%s' "$line" | ajq - user_id -s 2>/dev/null || true)
    dev=$(log_entry_device "$line")
    project=$(printf '%s' "$line" | ajq - project -s 2>/dev/null || true)
    source=$(printf '%s' "$line" | ajq - source_home -s 2>/dev/null || true)
    backup=$(printf '%s' "$line" | ajq - backup -s 2>/dev/null || true)
    home=$(printf '%s' "$line" | ajq - home -s 2>/dev/null || true)
    [ "$uid" = "null" ] && uid=
    out="$time_s  $(printf '%-8s' "$action")"
    [ -n "$uid" ] && out="$out  $(short_sess "$uid" "$dev")"
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

    printf '== session freshness\n'
    if [ -s "$copies" ]; then
        printf 'distinct sessions: %s   credential files: %s\n' \
            "$(awk -F'\t' '{ print $1 ":" $4 }' "$copies" | sort -u | wc -l)" "$(wc -l < "$copies")"
        awk -F'\t' -v now="$now" '
            function age(s,  d,h,m) {
                if (s < 0) s = 0
                d = int(s/86400); h = int((s%86400)/3600); m = int((s%3600)/60)
                if (d > 0) return d "d" h "h"
                if (h > 0) return h "h" m "m"
                return m "m"
            }
            NR == FNR { if ($1 != "") cnt[$1 ":" $4]++; next }
            $1 ":" $4 != prev {
                if (sess > 0) print ""
                sess++; prev = $1 ":" $4; first_iat = $2
                printf "session #%d: user_id=%s device_id=%s  (%d cop%s)\n", \
                    sess, $1, ($4 != "" ? $4 : "unknown"), cnt[prev], (cnt[prev] > 1 ? "ies" : "y")
                printf "  latest: %s\n", $5
                printf "          refreshed %s ago, refresh token expires in %s%s\n", \
                    age(now-$2), age($3-now), ($3 < now ? " [refresh EXPIRED]" : "")
                next
            }
            {
                printf "  stale:  %s (behind by %s)%s\n", $5, age(first_iat-$2), \
                    ($3 < now ? " [refresh EXPIRED]" : "")
            }
        ' "$copies" <(sort -t "$(printf '\t')" -k1,1 -k4,4 -k2,2nr "$copies")
    else
        printf 'no credential files found\n'
    fi

    printf '\n== drift check\n'
    local name home current state dhome deployed_uid deployed_dev last uid dev aline drift_out
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
            deployed_dev=$(log_entry_device "$last")
            uid=$(printf '%s' "$current" | cut -f1)
            dev=$(printf '%s' "$current" | cut -f4)
            if [ -n "$deployed_uid" ] && { [ "$deployed_uid" != "$uid" ] || { [ -n "$deployed_dev" ] && [ "$deployed_dev" != "$dev" ]; }; }; then
                printf '  home %s: DRIFTED — deployed as %s, now holds %s\n' \
                    "$dhome" "$(short_sess "$deployed_uid" "$deployed_dev")" "$(short_sess "$uid" "$dev")"
            fi
        done
        man_aliases | while IFS=$'\t' read -r aline key; do
            [ -n "$aline" ] || continue
            case $key in
                *:*)
                    if [ -z "$(freshest_for_session "$copies" "${key%%:*}" "${key#*:}" || true)" ] \
                        && ! man_slots | awk -F'\t' -v uid="${key%%:*}" -v dev="${key#*:}" \
                            '$5 == "excluded" && $3 == uid && ($4 == dev || ($4 == "" && dev == "")) { f = 1 } END { exit !f }'; then
                        printf '  alias %s: session %s missing everywhere\n' "$aline" "$(short_key "$key")"
                    fi ;;
                *)
                    if ! awk -F'\t' -v uid="$key" '$1 == uid { found = 1 } END { exit !found }' "$copies" \
                        && ! man_slots | awk -F'\t' -v uid="$key" \
                            '$5 == "excluded" && $3 == uid { f = 1 } END { exit !f }'; then
                        printf '  alias %s: account %s missing everywhere\n' "$aline" "$(short_uid "$key")"
                    fi ;;
            esac
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

cmd_register() { # SLOT AUTH_JSON — declare the session a slot is expected to hold
    local slot=$1 cred=$2 home uid dev old current cred_home
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    is_excluded "$slot" && die "slot '$slot' is excluded (private); run 'include $slot' before registering it"
    [ -f "$cred" ] || die "credential file not found: $cred"
    cred=$(cd "$(dirname "$cred")" && pwd -P)/$(basename "$cred")
    cred_home=$(dirname "$(dirname "$cred")")
    if is_excluded_home "$cred_home"; then
        local xslot
        xslot=$(man_slots | awk -F'\t' -v p="$cred_home" '$5 == "excluded" && $2 == p && !f { print $1; f = 1 }')
        die "$cred belongs to excluded slot '$xslot' (private); its credentials are never read. Run 'include $xslot' to lift this."
    fi
    local info
    info=$(cred_info "$cred") || die "unreadable credential: $cred"
    uid=$(printf '%s' "$info" | cut -f1)
    dev=$(printf '%s' "$info" | cut -f4)
    if [ -z "$dev" ] && [ -f "$cred_home/device_id" ]; then
        dev=$(head -c 64 "$cred_home/device_id" 2>/dev/null | tr -d '[:space:]')
    fi
    old=$(slot_expected "$slot")
    local old_dev
    old_dev=$(slot_expected_device "$slot")
    man_slot_set "$slot" "$home" "$uid" "$dev" "$(slot_flags "$slot")"
    man_session_note "$uid:$dev" "$home" "$(printf '%s' "$info" | cut -f2)"
    if [ -n "$old" ] && { [ "$old" != "$uid" ] || { [ -n "$old_dev" ] && [ "$old_dev" != "$dev" ]; }; }; then
        printf 're-registered %s: expected session was %s, now %s\n' \
            "$slot" "$(short_sess "$old" "$old_dev")" "$(short_sess "$uid" "$dev")"
    else
        printf 'registered %s: expected session %s\n' "$slot" "$(short_sess "$uid" "$dev")"
    fi
    current=$(slot_current "$home" || true)
    if [ -n "$current" ]; then
        if [ "$(printf '%s' "$current" | cut -f1)" != "$uid" ] \
            || { [ -n "$dev" ] && [ "$(printf '%s' "$current" | cut -f4)" != "$dev" ]; }; then
            printf 'note: %s currently holds %s — it will show DRIFTED until re-logged into %s\n' \
                "$slot" "$(short_sess "$(printf '%s' "$current" | cut -f1)" "$(printf '%s' "$current" | cut -f4)")" \
                "$(short_sess "$uid" "$dev")"
        fi
    else
        printf 'note: %s currently has no readable credentials; it will show empty until logged in\n' "$slot"
    fi
}

cmd_exclude() { # SLOT — never read, scan, or deploy from this slot's home
    local slot=$1 home expected expected_dev aliases
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    if is_excluded "$slot"; then
        printf 'slot %s is already excluded\n' "'$slot'"
        return 0
    fi
    expected=$(slot_expected "$slot")
    expected_dev=$(slot_expected_device "$slot")
    man_slot_set "$slot" "$home" "$expected" "$expected_dev" "excluded"
    printf 'excluded %s (%s)\n' "'$slot'" "$home"
    printf '  its credentials will not be read, scanned, or deployed by any subcommand\n'
    printf '  undo with: kimi-project.sh include %s\n' "$slot"
    if [ -n "$expected" ]; then
        aliases=$(aliases_for_session "$expected" "$expected_dev")
        [ -n "$aliases" ] || aliases=$(aliases_legacy_for_uid "$expected")
        if [ -n "$aliases" ]; then
            printf '  note: alias(es) %s point to this session; deploys by alias will fail while it exists only here\n' "$aliases"
        fi
    fi
}

cmd_include() { # SLOT — clear the exclusion flag
    local slot=$1 home expected expected_dev
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'. Known: $(discover_slots | cut -f1 | paste -sd' ' -)"
    is_excluded "$slot" || { printf 'slot %s is not excluded\n' "'$slot'"; return 0; }
    expected=$(slot_expected "$slot")
    expected_dev=$(slot_expected_device "$slot")
    man_slot_set "$slot" "$home" "$expected" "$expected_dev" ""
    printf 'included %s (%s); it is readable, scannable, and deployable again\n' "'$slot'" "$home"
}

cmd_alias() { # NAME SLOT [--force] — bind an alias to the session currently in a slot
    local name=$1 slot=$2 home current uid dev key existing tmp
    case $name in
        [a-z0-9] | [a-z0-9]*[a-z0-9-]) ;;
        *) die "alias '$name' must be lowercase letters, digits, hyphens" ;;
    esac
    printf '%s' "$name" | grep -q '^[a-z0-9][a-z0-9-]*$' \
        || die "alias '$name' must be lowercase letters, digits, hyphens"
    home=$(slot_home "$slot")
    [ -n "$home" ] || die "unknown slot '$slot'"
    is_excluded "$slot" && die "slot '$slot' is excluded (private); run 'include $slot' before aliasing its session"
    current=$(slot_current "$home" || true)
    [ -n "$current" ] || die "slot '$slot' has no readable credentials — log in first"
    uid=$(printf '%s' "$current" | cut -f1)
    dev=$(printf '%s' "$current" | cut -f4)
    key="$uid:$dev"
    existing=$(man_alias_get "$name")
    if [ -n "$existing" ] && [ "$existing" != "$key" ] && [ "$OPT_FORCE" != 1 ]; then
        die "alias '$name' already points to $(short_key "$existing"); use --force to rebind to $(short_key "$key")"
    fi
    man_alias_set "$name" "$key"
    man_session_note "$key" "$home" "$(printf '%s' "$current" | cut -f2)"
    printf 'alias %s -> %s (session currently in slot %s)\n' "$name" "$(short_key "$key")" "'$slot'"
}

cmd_unalias() { # NAME
    local name=$1 existing
    existing=$(man_alias_get "$name")
    [ -n "$existing" ] || die "no alias '$name'"
    man_alias_set "$name" ""
    printf 'removed alias %s (was %s)\n' "$name" "$(short_key "$existing")"
}

resolve_selector() { # SELECTOR COPIES_FILE -> "session\tUID\tDEVICE" or "slot\tNAME"
    local sel=$1 copies=$2 key uid matches dev_matches
    key=$(man_alias_get "$sel")
    if [ -n "$key" ]; then
        case $key in
            *:*)
                printf 'session\t%s\t%s\n' "${key%%:*}" "${key#*:}"
                return 0 ;;
            *)
                matches=$(awk -F'\t' -v uid="$key" '$1 == uid { print $1 "\t" $4 }' "$copies" | sort -u)
                case $(printf '%s\n' "$matches" | grep -c .) in
                    1) printf 'session\t%s\t%s\n' "$(printf '%s' "$matches" | cut -f1)" "$(printf '%s' "$matches" | cut -f2)" ;;
                    0) die "alias '$sel' points to account $(short_uid "$key"), which no slot or logged project holds" ;;
                    *) die "alias '$sel' points to account $(short_uid "$key"), which has several live sessions: $(printf '%s\n' "$matches" | while IFS=$'\t' read -r u d; do short_sess "$u" "$d"; done | paste -sd' ' -)
Rebind it to one session: alias $sel <slot>" ;;
                esac
                return 0 ;;
        esac
    fi
    if discover_slots | cut -f1 | grep -x -F -- "$sel" >/dev/null; then printf 'slot\t%s\n' "$sel"; return 0; fi
    dev_matches=$(awk -F'\t' -v p="$sel" '$4 != "" && index($4, p) == 1 { print $1 "\t" $4 }' "$copies" | sort -u)
    case $(printf '%s\n' "$dev_matches" | grep -c .) in
        1) printf 'session\t%s\t%s\n' "$(printf '%s' "$dev_matches" | cut -f1)" "$(printf '%s' "$dev_matches" | cut -f2)"; return 0 ;;
        0) ;;
        *) die "selector '$sel' is ambiguous between sessions: $(printf '%s\n' "$dev_matches" | while IFS=$'\t' read -r u d; do short_sess "$u" "$d"; done | paste -sd' ' -)" ;;
    esac
    matches=$(awk -F'\t' -v p="$sel" 'index($1, p) == 1 { print $1 "\t" $4 }' "$copies" | sort -u)
    case $(printf '%s\n' "$matches" | grep -c .) in
        1) printf 'session\t%s\t%s\n' "$(printf '%s' "$matches" | cut -f1)" "$(printf '%s' "$matches" | cut -f2)" ;;
        0) die "unknown selector '$sel'. Valid: $( { man_aliases | cut -f1; discover_slots | cut -f1; } | sort -u | paste -sd' ' -)" ;;
        *) die "selector '$sel' is ambiguous between sessions: $(printf '%s\n' "$matches" | while IFS=$'\t' read -r u d; do short_sess "$u" "$d"; done | paste -sd' ' -)
Use an alias or slot name to pick one login." ;;
    esac
}

holds_freshest_copy() { # HOME -> rc 0 when HOME holds the freshest known copy of its session
    local home=$1 current uid dev copies best
    current=$(slot_current "$home" || true)
    [ -n "$current" ] || return 1
    uid=$(printf '%s' "$current" | cut -f1)
    dev=$(printf '%s' "$current" | cut -f4)
    copies=$(mktemp); { collect_copies; home_creds "$home"; } > "$copies"
    best=$(freshest_for_session "$copies" "$uid" "$dev" || true)
    rm -f "$copies"
    [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f5)" = "$(printf '%s' "$current" | cut -f5)" ]
}

session_seat_covers() { # HOME UID DEVICE IAT -> rc 0 when a registered seat of the session holds iat >= IAT
    local home=$1 uid=$2 dev=$3 iat=$4 line path s_current s_iat
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        path=$(printf '%s' "$line" | cut -f2)
        [ "$path" = "$home" ] && continue
        s_current=$(slot_current "$path" || true)
        s_iat=$(printf '%s' "$s_current" | cut -f2)
        case $s_iat in '' | *[!0-9]*) s_iat=0 ;; esac
        [ "$s_iat" -ge "$iat" ] && return 0
    done < <(man_slots | awk -F'\t' -v uid="$uid" -v dev="$dev" \
        '$3 == uid && ($4 == dev || ($4 == "" && dev == "")) && $5 != "excluded"')
    return 1
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

copy_auth() { # SRC_HOME DST_HOME — copy config.toml + credentials/ with home perms
    local src=$1 dst=$2
    mkdir -p "$dst"
    if [ -e "$src/config.toml" ]; then
        cp -p "$src/config.toml" "$dst/config.toml"
        chmod 600 "$dst/config.toml"
    fi
    if [ -d "$src/credentials" ]; then
        mkdir -p "$dst/credentials"
        chmod 700 "$dst/credentials"
        cp -a "$src/credentials/." "$dst/credentials/"
        find "$dst/credentials" -type f -exec chmod 600 {} +
    fi
}

rescue_to_seats() { # HOME — copy HOME's auth into every registered canonical home of the SAME session that is older
    RESCUED_TO_SEAT=0
    local home=$1 current uid dev iat
    current=$(slot_current "$home" || true)
    [ -n "$current" ] || return 0
    uid=$(printf '%s' "$current" | cut -f1)
    iat=$(printf '%s' "$current" | cut -f2)
    dev=$(printf '%s' "$current" | cut -f4)
    local line name path s_current s_iat
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        name=$(printf '%s' "$line" | cut -f1)
        path=$(printf '%s' "$line" | cut -f2)
        if [ "$path" = "$home" ]; then continue; fi
        s_current=$(slot_current "$path" || true)
        s_iat=$(printf '%s' "$s_current" | cut -f2)
        if [ -z "$s_iat" ] || [ "$iat" -gt "$s_iat" ]; then
            rm -f "$path/config.toml"
            rm -rf "$path/credentials"
            copy_auth "$home" "$path"
            printf 'note: rescued newer copy of %s into canonical home %s (slot %s)\n' \
                "$(short_sess "$uid" "$dev")" "$path" "$name"
            append_log rescue "user_id=$uid" "device_id=$dev" "source_home=$home" "home=$path" "cred_iat=$iat"
            man_session_note "$uid:$dev" "$path" "$iat"
            RESCUED_TO_SEAT=1
        fi
    done < <(man_slots | awk -F'\t' -v uid="$uid" -v dev="$dev" \
        '$3 == uid && ($4 == dev || ($4 == "" && dev == "")) && $5 != "excluded"')
}

require_clear_or_forced() { # HOME — occupied-home gate for deploy
    project_has_home "$1" || return 0
    [ "$OPT_FORCE" = 1 ] || die "$1 already holds an account.
Use --force to overwrite it (no backup), or --force-with-backup to back it up to .backup/ first."
}

replace_home_auth() { # HOME — forced replace: rescue newer auth to canonical homes, back up when asked, then clear
    local home=$1 current uid dev
    rescue_to_seats "$home"
    if [ "$RESCUED_TO_SEAT" = 0 ] && holds_freshest_copy "$home"; then
        if [ "$OPT_FORCE_BACKUP" = 1 ]; then
            printf 'note: %s holds the freshest known copy of its session; it is preserved in .backup/\n' \
                "$home"
        else
            printf 'warning: %s holds the freshest known copy of its session; overwriting with no backup\n' \
                "$home"
        fi
    fi
    if [ "$OPT_FORCE_BACKUP" = 1 ]; then
        current=$(slot_current "$home" || true)
        uid=; dev=
        if [ -n "$current" ]; then
            uid=$(printf '%s' "$current" | cut -f1)
            dev=$(printf '%s' "$current" | cut -f4)
        fi
        backup_home "$home"
        append_log backup "user_id=$uid" "device_id=$dev" "home=$home"
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
        xslot=$(man_slots | awk -F'\t' -v p="$home" '$5 == "excluded" && $2 == p && !f { print $1; f = 1 }')
        die "$home is excluded (private); deploy would touch its credentials. Run 'include $xslot' to lift this."
    fi
    require_clear_or_forced "$home"
    now=$(date +%s)
    copies=$(mktemp)
    collect_copies > "$copies"

    local source source_home uid dev iat exp cred_file
    if [ -n "$OPT_FROM" ]; then
        is_excluded "$OPT_FROM" && die "slot '$OPT_FROM' is excluded (private); it is never a deploy source. Run 'include $OPT_FROM' to lift this."
        source_home=$(slot_home "$OPT_FROM")
        [ -n "$source_home" ] || die "unknown slot '$OPT_FROM'"
        source=$(slot_current "$source_home" || true)
        [ -n "$source" ] || die "slot '$OPT_FROM' has no readable credentials — log in first"
        uid=$(printf '%s' "$source" | cut -f1)
        dev=$(printf '%s' "$source" | cut -f4)
        local expected expected_dev
        expected=$(slot_expected "$OPT_FROM")
        expected_dev=$(slot_expected_device "$OPT_FROM")
        if [ -n "$expected" ] && { [ "$expected" != "$uid" ] || { [ -n "$expected_dev" ] && [ "$expected_dev" != "$dev" ]; }; } \
            && [ "$OPT_FORCE" != 1 ]; then
            die "slot '$OPT_FROM' is DRIFTED: expected $(short_sess "$expected" "$expected_dev"), holds $(short_sess "$uid" "$dev"). Use --force to deploy anyway."
        fi
        local best best_iat
        best=$(freshest_for_session "$copies" "$uid" "$dev" || true)
        best_iat=$(printf '%s' "$best" | cut -f2)
        if [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f5)" != "$(printf '%s' "$source" | cut -f5)" ] \
            && [ "$best_iat" -gt "$(printf '%s' "$source" | cut -f2)" ] && [ "$OPT_FORCE" != 1 ]; then
            rm -f "$copies"
            die "slot '$OPT_FROM' is not the freshest copy of $(short_sess "$uid" "$dev"); $(dirname "$(dirname "$(printf '%s' "$best" | cut -f5)")") is newer by $(fmt_age $((best_iat - $(printf '%s' "$source" | cut -f2)))).
Deploy from there instead (selector: $(short_sess "$uid" "$dev")), or use --force."
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
            best=$(freshest_for_session "$copies" "$(printf '%s' "$source" | cut -f1)" "$(printf '%s' "$source" | cut -f4)" || true)
            [ -n "$best" ] && [ "$(printf '%s' "$best" | cut -f2)" -gt "$(printf '%s' "$source" | cut -f2)" ] && source=$best
        else
            local rdev
            rdev=$(printf '%s' "$resolved" | cut -f3)
            source=$(freshest_for_session "$copies" "$value" "$rdev" || true)
            if [ -z "$source" ]; then
                rm -f "$copies"
                die "session $(short_sess "$value" "$rdev") is not present in any slot or logged project.
Log it into a slot first (e.g. kimi-<suffix> login), then retry."
            fi
        fi
    fi

    uid=$(printf '%s' "$source" | cut -f1)
    iat=$(printf '%s' "$source" | cut -f2)
    exp=$(printf '%s' "$source" | cut -f3)
    dev=$(printf '%s' "$source" | cut -f4)
    cred_file=$(printf '%s' "$source" | cut -f5)
    source_home=$(dirname "$(dirname "$cred_file")")
    [ "$source_home" = "$home" ] \
        && die "source and target are the same home ($home); nothing to deploy"

    rescue_to_seats "$source_home"

    if project_has_home "$home"; then
        replace_home_auth "$home"
    fi

    copy_auth "$source_home" "$home"

    append_log deploy "selector=$sel" "user_id=$uid" "device_id=$dev" "source_home=$source_home" \
        "home=$home" "cred_iat=$iat"
    man_session_note "$uid:$dev" "$source_home" "$iat"
    rm -f "$copies"

    local aliases
    aliases=$(aliases_for_session "$uid" "$dev")
    [ -n "$aliases" ] && aliases=" ($aliases)"
    printf 'deployed %s%s from %s\n' "$(short_sess "$uid" "$dev")" "$aliases" "$source_home"
    printf '  credential refreshed %s ago; refresh TTL %s\n' "$(fmt_age $((now - iat)))" "$(fmt_age $((exp - now)))"
    printf '  into %s\n' "$home"
    if [ -z "$via_env" ]; then
        printf 'next: export KIMI_CODE_HOME=%s\n' "$home"
        printf '      (or from its project dir: source ~/set-kimi-home-as-pwd.sh)\n'
    fi
}

cmd_undeploy() { # [--project DIR] [--force|--force-with-backup] — return a project's session home
    local home current uid dev iat
    home=$(deploy_home)
    if is_excluded_home "$home"; then
        local xslot
        xslot=$(man_slots | awk -F'\t' -v p="$home" '$5 == "excluded" && $2 == p && !f { print $1; f = 1 }')
        die "$home is excluded (private); undeploy would touch its credentials. Run 'include $xslot' to lift this."
    fi
    project_has_home "$home" || die "$home holds no deployed auth — nothing to undeploy"

    current=$(slot_current "$home" || true)
    if [ -z "$current" ] && [ "$OPT_FORCE" != 1 ]; then
        die "$home has no readable credentials to return; use --force to remove its auth state anyway"
    fi
    uid=; dev=; iat=
    if [ -n "$current" ]; then
        uid=$(printf '%s' "$current" | cut -f1)
        iat=$(printf '%s' "$current" | cut -f2)
        dev=$(printf '%s' "$current" | cut -f4)
    fi

    # Return the session: rescue a fresher copy back into its registered slot home(s).
    rescue_to_seats "$home"
    if [ "$RESCUED_TO_SEAT" = 0 ] && [ -n "$current" ] && [ "$OPT_FORCE" != 1 ] \
        && ! session_seat_covers "$home" "$uid" "$dev" "$iat"; then
        die "$home holds the freshest known copy of $(short_sess "$uid" "$dev") and no registered slot home holds an equally fresh copy.
Use --force-with-backup to keep it in $home/.backup/, or --force to discard it."
    fi
    if [ "$OPT_FORCE_BACKUP" = 1 ]; then
        backup_home "$home"
        append_log backup "user_id=$uid" "device_id=$dev" "home=$home"
        printf 'previous auth backed up to %s\n' "$home/.backup"
    fi

    rm -f "$home/config.toml"
    rm -rf "$home/credentials"
    append_log undeploy "user_id=$uid" "device_id=$dev" "home=$home" "cred_iat=${iat:-0}"
    if [ "$RESCUED_TO_SEAT" = 1 ]; then
        printf 'undeployed %s: session returned to its registered slot home; auth removed from %s\n' \
            "$(short_sess "$uid" "$dev")" "$home"
    else
        printf 'undeployed %s: auth removed from %s\n' "$(short_sess "$uid" "$dev")" "$home"
    fi
}

cmd_backup() { # [--project DIR] — copy the target home's auth into <home>/.backup/
    local home current uid dev
    home=$(target_home)
    is_excluded_home "$home" \
        && die "$home is excluded (private); backup would read its credentials. Run 'include <slot>' to lift this."
    project_has_home "$home" || die "$home has no config.toml or credentials/ — nothing to back up"

    current=$(slot_current "$home" || true)
    uid=; dev=
    if [ -n "$current" ]; then
        uid=$(printf '%s' "$current" | cut -f1)
        dev=$(printf '%s' "$current" | cut -f4)
    fi

    backup_home "$home"
    append_log backup "user_id=$uid" "device_id=$dev" "home=$home"
    printf 'backed up %s\n' "$home"
    printf '  into %s (single backup entry per home)\n' "$home/.backup"
    if [ -n "$uid" ]; then
        printf '  session: %s\n' "$(short_sess "$uid" "$dev")"
    fi
    printf '  undo with: kimi-project.sh restore   (same target resolution as backup)\n'
}

cmd_restore() { # [--project DIR] — overwrite the target home's auth with its .backup/
    local home current uid dev had_live
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
    uid=; dev=
    if [ -n "$current" ]; then
        uid=$(printf '%s' "$current" | cut -f1)
        dev=$(printf '%s' "$current" | cut -f4)
    fi
    append_log restore "user_id=$uid" "device_id=$dev" "home=$home"
    printf 'restored %s from %s\n' "$home" "$home/.backup"
    if [ -n "$uid" ]; then
        printf '  session: %s\n' "$(short_sess "$uid" "$dev")"
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

An auth session is one independent OAuth login, identified by (user_id,
device_id) — two logins of the same account are distinct sessions. Copies of
the same session stay linked: freshness is ranked per session and a newer copy
is rescued back into the session's registered slot home(s).

Read-only:
  list                          show slots (with last-deploy target and freshest-auth
                                location per session), aliases, session tracking, drift
  status [--project DIR]        show a project's session state (default: cwd)
  log [COUNT]                   show deployment log (default 20 entries)
  scan [PATH ...]               per-session freshness + drift audit over slots and logged
                                projects; extra PATHs may be homes, projects, or parents

Mutating:
  deploy <selector> [opts]      copy a session's config+credentials into the target home
                                selector: alias, slot name, or id prefix (user_id or
                                device_id — a prefix matching several sessions is refused)
                                target: --project DIR, else $KIMI_CODE_HOME, else cwd's .kimi-code;
                                missing or empty targets are created/filled without flags
                                canonical convergence: a newer copy is always rescued into
                                the slot home(s) registered to its session — both when the
                                freshest source copy lives outside them and, on overwrite,
                                when the target's own auth is newer (logged as rescue);
                                an unrescuable freshest copy only warns
                                opts: --from SLOT  --project DIR
                                      --force              overwrite an occupied home (no backup)
                                      --force-with-backup  back the home up to .backup/ first
  undeploy [opts]               return a project's auth: rescue its session back into the
                                registered slot home(s) when fresher, then remove the
                                project's config.toml + credentials/. Refuses to remove
                                the session's freshest copy when no registered slot home
                                holds an equally fresh copy, unless --force (discard) or
                                --force-with-backup (keep in .backup/). Target resolution
                                is the same as deploy.
  backup [--project DIR]        copy the target home's config+credentials into its .backup/
                                (single entry; overwrites the previous backup). Target home:
                                --project DIR, else $KIMI_CODE_HOME, else ~/.kimi-code
  restore [--project DIR]       overwrite the target home's config+credentials with the
                                contents of its .backup/ (same target resolution as backup)
  forget [--dead | PATH ...]    drop deployment-record entries: entries matching PATHs
                                (a home or its project dir), or with --dead every entry
                                whose home no longer exists. Homes themselves are the
                                caller's concern — forget never removes files
  register <slot> <auth.json>   declare the session a slot is expected to hold; the
                                account and device ids are read from the given credential
                                file, never inferred from the slot's current contents
  alias <name> <slot> [--force] bind an alias to the session currently in a slot
  unalias <name>                remove an alias
  exclude <slot>                mark a slot private: never read, scanned, or deployed from
  include <slot>                lift the exclusion
EOF
}

OPT_PROJECT=; OPT_FROM=; OPT_FORCE=0; OPT_FORCE_BACKUP=0; OPT_DEAD=0
RESCUED_TO_SEAT=0
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
    register) ensure_manifest_v2; [ $# -eq 2 ] || { usage; exit 2; }; cmd_register "$1" "$2" ;;
    alias) ensure_manifest_v2; [ $# -ge 2 ] || { usage; exit 2; }; cmd_alias "$1" "$2" ;;
    unalias) ensure_manifest_v2; [ $# -eq 1 ] || { usage; exit 2; }; cmd_unalias "$1" ;;
    exclude) ensure_manifest_v2; [ $# -eq 1 ] || { usage; exit 2; }; cmd_exclude "$1" ;;
    include) ensure_manifest_v2; [ $# -eq 1 ] || { usage; exit 2; }; cmd_include "$1" ;;
    deploy) ensure_manifest_v2; [ $# -ge 1 ] || { usage; exit 2; }; cmd_deploy "$1" ;;
    undeploy) ensure_manifest_v2; cmd_undeploy ;;
    backup) ensure_manifest_v2; cmd_backup ;;
    restore) ensure_manifest_v2; cmd_restore ;;
    forget) cmd_forget "$@" ;;
    -h | --help | help) usage ;;
    *) usage; exit 2 ;;
esac
