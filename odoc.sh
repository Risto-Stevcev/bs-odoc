#!/bin/bash

readonly PKG_NAME_RE='.*\"name\":\s*"\(.*\)".*'
readonly REMOVE_NAMESPACE_RE='^[^\/]*\/\(.*\)'
readonly PKG_NAME=$(
  cat bsconfig.json \
  | grep "\"name\":" \
  | sed -e 's/'"${PKG_NAME_RE}"'/\1/g' \
        -e 's/'"${REMOVE_NAMESPACE_RE}"'/\1/'
)
readonly DOCS=${1:-docs}

readonly ODOC=$(which odoc)
readonly LIB=./lib/bs

readonly CMT_FILES=$(find ${LIB} -name "*.cmt")
readonly ODOC_FILES=$(echo ${CMT_FILES} | sed "s/cmt/odoc/g")
readonly INCLUDES=$(find ${LIB} -type d | tail -n +2 | xargs echo | sed -e 's/ / -I /g' -e 's/^/-I /')

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

  # Remove the width restriction and set the left margin to be the same as the right
  find ${DOCS} -name "*.css" -exec \
    sed -i -e 's/max-width: 90ex;//' -e 's/margin-left: calc(10vw + 20ex);/margin-left: 20px;/' {} +

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
