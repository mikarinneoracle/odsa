      - uses: actions/checkout@v3
      - name: 'Set up latest Oracle JDK 17'
        uses: oracle-actions/setup-java@v1
        with:
         website: oracle.com
         release: 17

      - name: Install Oracle Sqlcl
        uses: cpruvost/setup-sqlcl@v1.0.0
        
      - run: |
          wget ${{ secrets.SAS }} -O Wallet.zip
          mkdir -p ./network/admin
          mv Wallet.zip ./network/admin/
          export conn=${{ secrets.DBNAME }}_tp
          export pwd=${{ secrets.PASSWORD }}
          sh create_apex.sh
          cd network/admin
          unzip -q Wallet.zip
          export apex=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${{ secrets.DBNAME }}.adb.${{ secrets.REGION }}.oraclecloudapps.com/ords/r/priceadmin/price-admin/login")
          export ords=$(grep -oP '(?<=service_name=)[^_]*' tnsnames.ora | echo "https://$(head -n 1)-${{ secrets.DBNAME }}.adb.${{ secrets.REGION }}.oraclecloudapps.com/ords/priceadmin")
          echo "APEX URL: ${apex}"
          echo "ORDS URL: ${ords}"
          cd ../../
          cd html
          sed -i "s|ORDS_URL|${ords}|g" vue.js
          sed -i "s|APEX_URL|${apex}|g" vue.js