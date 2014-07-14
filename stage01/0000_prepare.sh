
source stage0n_variables
source stage01_variables

PKGNAME=prepare
PKGVERSION=0.1

mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET}
ln -sfv . ${CLFS}/cross-tools/${CLFS_TARGET}/usr

exit 0
