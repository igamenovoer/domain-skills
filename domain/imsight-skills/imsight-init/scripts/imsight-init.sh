#!/usr/bin/env bash
set -euo pipefail

script_dir="$(
  cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1
  pwd
)"
skill_dir="$(dirname -- "$script_dir")"
skills_root="$(dirname -- "$skill_dir")"

skill_names=()
skill_entrypoints=()

for candidate in "$skills_root"/imsight-*; do
  [[ -d "$candidate" ]] || continue

  candidate_dir="$(cd -P -- "$candidate" >/dev/null 2>&1 && pwd)"
  [[ "$candidate_dir" != "$skill_dir" ]] || continue

  entrypoint="$candidate_dir/SKILL.md"
  [[ -f "$entrypoint" ]] || continue

  skill_names+=("$(basename -- "$candidate")")
  skill_entrypoints+=("$entrypoint")
done

if [[ ${#skill_entrypoints[@]} -eq 0 ]]; then
  echo "imsight-init: no sibling imsight-* skills with SKILL.md found under $skills_root" >&2
  exit 1
fi

printf 'Imsight skills root: %s\n' "$skills_root"
printf 'Discovered sibling Imsight skill entrypoints:\n'
for ((index = 0; index < ${#skill_entrypoints[@]}; index++)); do
  printf -- '- %s: %s\n' "${skill_names[$index]}" "${skill_entrypoints[$index]}"
done
printf '\nAgent instruction: Inspect each listed SKILL.md name and description frontmatter to recover routing awareness. Read a matching SKILL.md completely before using that skill.\n'
