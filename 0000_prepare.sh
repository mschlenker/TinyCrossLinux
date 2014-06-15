
source stage01_variables

mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET}
mkdir -p ${SRCDIR}
ln -sfv . ${CLFS}/cross-tools/${CLFS_TARGET}/usr
