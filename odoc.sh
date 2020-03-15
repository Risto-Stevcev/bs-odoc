#!/bin/bash

readonly PKG_NAME_RE='.*\"name\":\s*"\(.*\)".*'
readonly REMOVE_NAMESPACE_RE='^[^\/]*\/\(.*\)'
readonly PKG_NAME=$(
  cat bsconfig.json \
  | grep "\"name\":" \
  | sed -e 's/'"${PKG_NAME_RE}"'/\1/g' \
        -e 's/'"${REMOVE_NAMESPACE_RE}"'/\1/'
)

DOCS="docs"  # Default folder
readonly ODOC=$(which odoc)
readonly LIB=./lib/bs

# Creates args for `find` to excludes .cmt extensions for files that have .cmti
readonly CMTI_EXCLUDES=$(find ${LIB} -name *.cmti | sed -e "s/cmti/cmt/g" | awk -vRS="" -vOFS=" ! -path " '$1=" ! -path "$1')
readonly CMT_FILES=$(find ${LIB} -name *.cmti -o -name *.cmt $CMTI_EXCLUDES)
readonly ODOC_FILES=$(echo ${CMT_FILES} | sed "s/cmti\?/odoc/g")
readonly INCLUDES=$(find ${LIB} -type d | tail -n +2 | xargs echo | sed -e 's/ / -I /g' -e 's/^/-I /')


function usage {
  cat <<EOF
Usage: $0 [ OPTION ]

Options:

  -d  The directory to place the docs in. Defaults to docs/
  -i  An optional index.mld file (place it in the project root)
  -h  Help
EOF
}


# Get options
while getopts ":d:i:h" opts; do
  case "${opts}" in
    d)
      DOCS=${OPTARG};;
    i)
      INDEX_FILE=${OPTARG}
      INDEX_FILE_ODOC=$(echo ${INDEX_FILE}  | sed "s/mld/odoc/g" | awk '{print "page-" $1}')
      ;;
    h)
      usage
      exit 0
  esac
done



function cleanup_folder {
  echo "<< Cleanup folder..."

  rm -rf ${DOCS}
  mkdir ${DOCS}

  echo ">> Done!"
}

function compile_docs {
  echo "<< Compiling docs..."

  for file in ${CMT_FILES}; do
    ${ODOC} compile \
      ${INCLUDES} \
      --pkg=${PKG_NAME} \
      ${file}
  done

  if [ ${INDEX_FILE} ]; then
    ${ODOC} compile \
      ${INCLUDES} \
      --pkg=${PKG_NAME} \
      ${INDEX_FILE}
  fi

  echo ">> Done!"
}

function generate_html {
  echo "<< Generating HTML..."

  for file in ${ODOC_FILES}; do
    ${ODOC} html \
      ${INCLUDES} \
      -o ${DOCS} \
      --semantic-uris \
      ${file}
  done

  if [ ${INDEX_FILE_ODOC} ]; then
    ${ODOC} html \
      ${INCLUDES} \
      -o ${DOCS} \
      --semantic-uris \
      ${INDEX_FILE_ODOC}

    rm ${INDEX_FILE_ODOC}
  fi

  echo ">> Done!"
}

function cleanup_strings {
  echo "<< Cleanup strings..."

  # Remove the strange characters coming from external declarations using the bucklescript ppx
  find ${DOCS} -type f -name "*.html" -exec \
    perl -i.bak -0777 -pe 's|\&quot;BS:.*?@\&quot;|\&quot;BS\&quot;|gs' {} +

  echo ">> Done!"
}

function add_support_files {
  echo "<< Add support files..."

  ${ODOC} support-files -o ${DOCS}

  echo ">> Done!"
}

function run_odoc {
  cleanup_folder
  compile_docs
  generate_html
  cleanup_strings
  add_support_files
  echo "Finished!"
}

if which odoc; then
  run_odoc
else
  echo -e "\nCouldn't find odoc. Make sure it's on your \$PATH"
  exit 1
fi
