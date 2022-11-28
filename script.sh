      - run: |          
          export dbname=${{ secrets.DBNAME }}
          export region=${{ secrets.REGION }}
          export conn=${{ secrets.DBNAME }}_tp
          export pwd=${{ secrets.PASSWORD }}
          wget ${{ secrets.SAS }} -O Wallet.zip
          mkdir -p ./network/admin
          mv Wallet.zip ./network/admin/
          wget 
          https://objectstorage.eu-amsterdam-1.oraclecloud.com/p/BydeV7ct283Y4F2S9PECPEyeNI-U3xoaghdLQ0EuzNUEDIMoieyqu5uA7xJ-syyq/n/frsxwtjslf35/b/oracledb/o/jdk-11.0.16_linux-x64_bin.tar.gz  -q
          tar -xzf jdk-11.0.16_linux-x64_bin.tar.gz
          export PATH=./jdk-11.0.16/bin:$PATH
          export JAVA_HOME=./jdk-11.0.16
          wget 
          https://objectstorage.eu-amsterdam-1.oraclecloud.com/p/rBz7NIZQsEXsXN6yqnLn8m9fLmTHZUY7Z5uhPBBUzsoiW0ceUoY1jyU5y7DjEWJx/n/frsxwtjslf35/b/oracledb/o/V1022102-01.zip -q
          unzip -q V1022102-01.zip
          sh create_apex.sh
          cd network/admin
          unzip -q Wallet.zip
          export apex=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${dbname}.adb.${region}.oraclecloudapps.com/ords/r/priceadmin/price-admin/login")
          export ords=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${dbname}.adb.${region}.oraclecloudapps.com/ords/priceadmin")
          echo "APEX URL: ${apex}"
          echo "ORDS URL: ${ords}"
          cd ../../
          cd html
          sed -i "s|ORDS_URL|${ords}|g" vue.js
          sed -i "s|APEX_URL|${apex}|g" vue.js
