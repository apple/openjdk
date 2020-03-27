#!/bin/sh -e

if [[ $(arch) == "arm64" ]] ; then
    echo "Re-execing build using Rosetta." >&2
    exec arch -x86_64 ${0} "${@}"
fi

SDK_NAME=macosx

CONCURRENCY=$(sysctl -n hw.activecpu)
CODE_SIGN_IDENTITY=${AMFITRUSTED_IDENTITY:--}
#DEBUG_LEVEL=slowdebug
#DEBUG_LEVEL=fastdebug
DEBUG_LEVEL=release

if [[ -z "${BOOTSTRAP_JDK}" ]] ; then
    if [[ -d /AppleInternal/Java/Home/13 ]] ; then
        BOOTSTRAP_JDK=/AppleInternal/Java/Home/13
    else
        BOOTSTRAP_JDK=$(/usr/libexec/java_home)
    fi
fi

# Exporting this such that /usr/bin/clang uses it implictly
export SDKROOT=$(xcrun --sdk ${SDK_NAME} --show-sdk-path)
export PATH=/AppleInternal/Java/bin:$PATH

JDK_VERSION=14.0.2

do_jnf() {
    mkdir -p build/Frameworks
    xcodebuild install -project apple/JavaNativeFoundation/JavaNativeFoundation.xcodeproj -target JavaNativeFoundation -configuration Release DSTROOT="$(pwd)/build/Frameworks" CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}"
}

do_configure() {
    VARIANTS=$1
    DEBUG_LEVEL=$2
    TARGET=$3
    sh configure --with-debug-level=${DEBUG_LEVEL} \
                 --openjdk-target=${TARGET} \
                 --with-jvm-variants="${VARIANTS}" \
                 --with-toolchain-type=clang \
                 --disable-hotspot-gtest \
                 --disable-javac-server \
                 --disable-full-docs \
                 --disable-manpages \
                 --with-vendor-name="Apple Developer Technologies" \
                 --with-macosx-bundle-id-base=com.apple.dt.java \
                 --with-version-opt="" \
                 --with-sdk-name=${SDK_NAME} \
                 --with-macosx-codesign-identity="${CODE_SIGN_IDENTITY}" \
                 --with-boot-jdk="${BOOTSTRAP_JDK}" \
                 --with-libffi-lib="${SDKROOT}/usr/lib" \
                 --with-libffi-include="${SDKROOT}/usr/include/ffi" \
                 --disable-warnings-as-errors \
                 --with-extra-cflags="-F$(pwd)/build/Frameworks" \
                 --with-extra-cxxflags="-F$(pwd)/build/Frameworks" \
                 --with-extra-ldflags="-F$(pwd)/build/Frameworks" \
                 BUILD_CC=/usr/bin/clang \
                 BUILD_CXX=/usr/bin/clang++ \
                 "${@}"
}

do_build() {
    VARIANTS=$1
    DEBUG_LEVEL=$2
    ARCH=$3
    make JOBS=${CONCURRENCY} CONF=macosx-${ARCH}-${VARIANTS//,/AND}-${DEBUG_LEVEL} LOG=debug images
    ditto build/Frameworks $(pwd)/build/macosx-${ARCH}-${VARIANTS//,/AND}-${DEBUG_LEVEL}/images/jdk-bundle/jdk-${JDK_VERSION}.jdk/Contents/Home/Frameworks
}

set -x

do_jnf

export DYLD_FALLBACK_FRAMEWORK_PATH=$(pwd)/build/Frameworks

do_configure "server" ${DEBUG_LEVEL} x86_64-apple-darwin18.0.0
do_build "server" ${DEBUG_LEVEL} x86_64

do_configure "zero" ${DEBUG_LEVEL} aarch64-apple-darwin20.0.0 --with-build-jdk="$(pwd)/build/macosx-x86_64-server-${DEBUG_LEVEL}/images/jdk-bundle/jdk-${JDK_VERSION}.jdk/Contents/Home"
do_build "zero" ${DEBUG_LEVEL} aarch64

UNIVERSAL_JDK=$(pwd)/build/jdk-${JDK_VERSION}-universal-zero-${DEBUG_LEVEL}.jdk
ARM64_JDK=$(pwd)/build/macosx-aarch64-zero-${DEBUG_LEVEL}/images/jdk-bundle/jdk-${JDK_VERSION}.jdk
X86_64_JDK=$(pwd)/build/macosx-x86_64-server-${DEBUG_LEVEL}/images/jdk-bundle/jdk-${JDK_VERSION}.jdk

rm -rf ${UNIVERSAL_JDK}

# We ditto both in case there is something present in one but not both.
ditto ${ARM64_JDK} ${UNIVERSAL_JDK}
ditto ${X86_64_JDK} ${UNIVERSAL_JDK}

for subdir in MacOS Home/bin Home/lib ; do
    pushd ${UNIVERSAL_JDK}/Contents/${subdir}

    find . -type f | while read file ; do
        FILE_TYPE=$(file "${file}")
        [[ ${FILE_TYPE} =~ "Mach-O" ]] || continue

        if [[ -f "${ARM64_JDK}/Contents/${subdir}/${file}" && -f "${X86_64_JDK}/Contents/${subdir}/${file}" ]] ; then
            lipo -output ${file} -create ${ARM64_JDK}/Contents/${subdir}/${file} ${X86_64_JDK}/Contents/${subdir}/${file}
        fi
    done
done

sed -i '' 's:x86_64:x86_64+arm64:' ${UNIVERSAL_JDK}/Contents/Home/release
