      - run: |
          wget ${{ secrets.SAS }} -O Wallet.zip
          mkdir -p ./network/admin
          mv Wallet.zip ./network/admin/
          export conn=${{ secrets.DBNAME }}_tp
          export pwd=${{ secrets.PASSWORD }}
          sh create_apex.sh
          cd network/admin
          unzip -q Wallet.zip
          apex=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${{ secrets.DBNAME }}.adb.${{ secrets.REGION }}.oraclecloudapps.com/ords/r/priceadmin/price-admin/login")
          ords=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${{ secrets.DBNAME }}.adb.${{ secrets.REGION }}.oraclecloudapps.com/ords/priceadmin")
          cd ../../
          cd html
          sed -i "s|ORDS_URL|${ords}|g" vue.js
          sed -i "s|APEX_URL|${apex}|g" vue.js