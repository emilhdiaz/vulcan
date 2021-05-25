#!/usr/bin/env bash

ROOT_DIR=$1
BUILD_DIR="${ROOT_DIR}/build/bin"
SCRIPT="${BUILD_DIR}/vulcan"

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
touch "${SCRIPT}"

for f in $(find libexec/vulcan -type f -name '*.sh' -not -name "*-configure.sh" -not -name "*-install.sh"); do
    echo "$f"
    cat "$f" >> "${SCRIPT}"
    printf "\n" >> "${SCRIPT}"
done
cat bin/vulcan >> "${SCRIPT}"

sed -ie '/source /d' "${SCRIPT}"
sed -ie '/\/usr\/bin\/env/d' "${SCRIPT}"
printf "#!/usr/bin/env zsh\n%s" "$(cat "${SCRIPT}")" > "${SCRIPT}"

chmod +x "${SCRIPT}"
rm "${SCRIPT}e"

echo "Combined all scripts into ${SCRIPT}"