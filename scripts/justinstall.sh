#!/bin/sh
# this is going to be problematic for oozie, since we've already released RPMs which are 2.0.5
# this default is different than all the others so that the script doesn't cause things to break when merged.
ALTISCALE_RELEASE=${ALTISCALE_RELEASE:-2.0.5}


export DEST_DIR=${INSTALL_DIR}/opt
mkdir -p --mode=0755 ${DEST_DIR}
cd ${DEST_DIR}
tar -xvzpf ${WORKSPACE}/oozie/distro/target/oozie-${ARTIFACT_VERSION}-distro/oozie-${ARTIFACT_VERSION}/oozie-client-${ARTIFACT_VERSION}.tar.gz
cp -r  ${WORKSPACE}/oozie/distro/target/oozie-${ARTIFACT_VERSION}-distro/oozie-${ARTIFACT_VERSION}/conf/ oozie-client-${ARTIFACT_VERSION}
# Make the Client RPM

export RPM_NAME=vcc-oozie-client-${ARTIFACT_VERSION}

cd ${RPM_DIR}

fpm --verbose \
--maintainer ops@altiscale.com \
--vendor Altiscale \
--provides ${RPM_NAME} \
-s dir \
-t rpm \
-n ${RPM_NAME} \
-v ${ALTISCALE_RELEASE} \
--epoch 1 \
--description "${DESCRIPTION}" \
--iteration ${DATE_STRING} \
--rpm-user root \
--rpm-group root \
-C ${INSTALL_DIR} \
opt

# Make the Server RPM

rm -rf ${DEST_DIR}
mkdir -p --mode=0755 ${DEST_DIR}
cd ${DEST_DIR}
tar -xvzpf ${WORKSPACE}/oozie/distro/target/oozie-${ARTIFACT_VERSION}-distro.tar.gz
export OOZIE_ROOT=${DEST_DIR}/oozie-${ARTIFACT_VERSION}
mkdir -p -m 0775 ${OOZIE_ROOT}/libext
cd ${OOZIE_ROOT}/libext
wget http://s3-us-west-1.amazonaws.com/verticloud-dependencies/ext-2.2.zip
EXTSUM=`sha1sum ext-2.2.zip | awk '{print $1}'`
if [ "${EXTSUM}" != "a949ddf3528bc7013b21b13922cc516955a70c1b" ]; then
  echo "FATAL: Filed to fetch the correct ext-2.2.zip"
fi
cd ${OOZIE_ROOT}/conf
rm -rf hadoop-conf
ln -s /etc/hadoop hadoop-conf
cd ${OOZIE_ROOT}/libtools
ln -s /opt/mysql-connector/mysql-connector.jar mysql-connector.jar
cd ${OOZIE_ROOT}/oozie-server/lib
ln -s /opt/mysql-connector/mysql-connector.jar mysql-connector.jar
cd ${OOZIE_ROOT}/bin
cp ${WORKSPACE}/scripts/pkgadd/oozie-status.sh .
chmod 755 oozie-status.sh

cd ${INSTALL_DIR}
find opt/oozie-${ARTIFACT_VERSION} -type d -print | awk '{print "/" $1}' > /tmp/$$.files
export DIRECTORIES=""
for i in `cat /tmp/$$.files`; do DIRECTORIES="--directories $i ${DIRECTORIES} "; done
export DIRECTORIES
rm -f /tmp/$$.files

export RPM_NAME=vcc-oozie-server-${ARTIFACT_VERSION}

cd ${RPM_DIR}

fpm --verbose \
-C ${INSTALL_DIR} \
--epoch 1
--maintainer ops@altiscale.com \
--vendor Altiscale \
--provides ${RPM_NAME} \
--depends alti-mysql-connector \
-s dir \
-t rpm \
-n ${RPM_NAME} \
-v ${ALTISCALE_RELEASE} \
${DIRECTORIES} \
--description "${DESCRIPTION}" \
--iteration ${DATE_STRING} \
--rpm-user oozie \
--rpm-group hadoop \
opt
