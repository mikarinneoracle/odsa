mkdir -p ./network/admin
mv /tmp/Wallet.zip ./network/admin/
wget https://objectstorage.eu-amsterdam-1.oraclecloud.com/p/BydeV7ct283Y4F2S9PECPEyeNI-U3xoaghdLQ0EuzNUEDIMoieyqu5uA7xJ-syyq/n/frsxwtjslf35/b/oracledb/o/jdk-11.0.16_linux-x64_bin.tar.gz -q
tar -xzf jdk-11.0.16_linux-x64_bin.tar.gz
export PATH=./jdk-11.0.16/bin:$PATH
export JAVA_HOME=./jdk-11.0.16
wget https://objectstorage.eu-amsterdam-1.oraclecloud.com/p/rBz7NIZQsEXsXN6yqnLn8m9fLmTHZUY7Z5uhPBBUzsoiW0ceUoY1jyU5y7DjEWJx/n/frsxwtjslf35/b/oracledb/o/V1022102-01.zip -q
unzip -q V1022102-01.zip
./sqlcl/bin/sql /nolog @./test.sql
