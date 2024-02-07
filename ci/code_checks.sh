#!/bin/bash

set -uo pipefail

declare -A ERRORS=(
  [code]="Check import. No warnings, and blocklist some optional dependencies"
  [doctests]="Python and Cython Doctests"
  [docstrings]="Validate docstrings (EX01, EX03, EX04, GL01, GL02, GL03, GL04, GL05, GL06, GL07, GL09, GL10, PR03, PR04, PR05, PR06, PR08, PR09, PR10, RT01, RT02, RT04, RT05, SA02, SA03, SA04, SS01, SS02, SS03, SS04, SS05, SS06)"
  [single-docs]="Partially validate docstrings (PR02)"
  [notebooks]="Notebooks"
)

BASE_DIR="$(dirname $0)/.."
RET=0

run_check() {
  local check=$1
  local msg="${ERRORS[$check]}"
  echo "$msg" ; echo

  case $check in
    code)
      python -W error -c "
        import sys
        import pandas
        blocklist = {'bs4', 'gcsfs', 'html5lib', 'http', 'ipython', 'jinja2', 'hypothesis', 'lxml', 'matplotlib', 'openpyxl', 'py', 'pytest', 's3fs', 'scipy', 'tables', 'urllib.request', 'xlrd', 'xlsxwriter'}
        import_mods = set(m.split('.')[0] for m in sys.modules) | set(sys.modules)
        mods = blocklist & import_mods
        if mods:
          sys.stderr.write('err: pandas should not import: {}\n'.format(', '.join(mods)))
          sys.exit(len(mods))
        "
      ;;

    doctests)
      python -c 'import pandas as pd; pd.test(run_doctests=True)'
      ;;

    docstrings)
      $BASE_DIR/scripts/validate_docstrings.py --format=actions --errors=EX01,EX03,EX04,GL01,GL02,GL03,GL04,GL05,GL06,GL07,GL09,GL10,PR03,PR04,PR05,PR06,PR08,PR09,PR10,RT01,RT02,RT04,RT05,SA02,SA03,SA04,SS01,SS02,SS03,SS04,SS05,SS06
      RET=$(($RET + $?))
      $BASE_DIR/scripts/validate_docstrings.py --format=actions --errors=PR02 --ignore_functions \
        pandas.Series.dt.to_period\
        # ... (list of ignored functions)
      RET=$(($RET + $?))
      ;;

    notebooks)
      jupyter nbconvert --execute $(find doc/source -name '*.ipynb') --to notebook
      RET=$(($RET + $?))
      ;;

    single-docs)
      python doc/make.py --warnings-are-errors --no-browser --single pandas.Series.value_counts
      python doc/make.py --warnings-are-errors --no-browser --single pandas.Series.str.split
      ;;

    *)
      echo "Unknown command $check. Usage: $0 [${!ERRORS[*]}]"
      exit 9999
      ;;
  esac

  echo "$msg DONE"
}

if [[ -v 1 ]]; then
  CHECK=$1
else
  CHECK=""
fi

run_check "$CHECK"
exit $RET
