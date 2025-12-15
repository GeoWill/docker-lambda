#!/bin/bash
echo "-----------------------"
echo "Creating lambda layer"
echo "-----------------------"

# Use dnf if available (AL2023), otherwise yum (AL2)
if command -v dnf &> /dev/null; then
    dnf install -y zip binutils findutils
else
    yum install -y zip binutils
fi

echo "Remove useless files"
rm -rdf $PREFIX/share/doc \
&& rm -rdf $PREFIX/share/man \
&& rm -rdf $PREFIX/share/cryptopp \
&& rm -rdf $PREFIX/share/hdf*

echo "Strip shared libraries"
cd $PREFIX && find lib/ -type f -name \*.so\* -exec strip {} \;

echo "Create archives"
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip lib/*.so*
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip share
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip bin/gdal* bin/ogr* bin/geos* bin/nearblack bin/postgres bin/pg_* bin/proj*

cp /tmp/package.zip /local/package.zip
