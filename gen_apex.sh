#!/bin/bash

export conn=pricing_high
export pwd=WelcomeFolks123#!
export schema=PRICEADMIN
export wsname=PRICEADMIN
export application_id=100
export tables_to_copy=Y

printf "set cloudconfig ./network/admin/wallet.zip\nconn admin/${pwd}@${conn}\n/\n" > upd.sql
printf "create user ${schema} identified by \"${pwd}\"\n/\n" >> upd.sql
printf "GRANT CONNECT, CREATE SESSION, CREATE CLUSTER, CREATE DIMENSION, CREATE INDEXTYPE, CREATE JOB, CREATE MATERIALIZED VIEW, CREATE OPERATOR, CREATE PROCEDURE, CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE, CREATE TRIGGER, CREATE TYPE, CREATE VIEW to ${schema};\n" >> upd.sql
printf "ALTER USER ${schema} quota unlimited on DATA;\n/\n" >> upd.sql
printf "conn ${schema}/${pwd}@${conn}\n" >> upd.sql
if [ -f "controller.xml" ]; then
   printf "lb update -changelog controller.xml\n" >> upd.sql
else
    echo "Controller.xml not found. Schema not copied to ${schema}."
fi

if [ -f "ords-rest_schema.xml" ]; then
   printf "lb update -changelog ords-rest_schema.xml\n" >> upd.sql
else
    echo "Ords-rest_schema not found. ORDS schema not copied to ${schema}."
fi

if [ "${tables_to_copy}" == "Y" ]; then
    echo "Copying tables data to ${schema}."
    if [ -f "data.xml" ]; then
           printf "lb update -changelog data.xml\n" >> upd.sql
    fi

    for filename in data*.xml; do
        [ -e "$filename" ] || continue
        if [ $filename != "data.xml" ]; then
           printf "lb update -changelog ${filename}\n" >> upd.sql
        fi
    done
fi

printf "\ntables\nexit" >> upd.sql
./sqlcl/bin/sql /nolog @./upd.sql

if [ -n "${wsname}" ]; then
    printf "set cloudconfig ./network/admin/wallet.zip\nconn admin/${pwd}@${conn}\n/\n" > upd_apex.sql
    printf "begin\n" >> upd_apex.sql
    printf "    for c1 in (select privilege\n" >> upd_apex.sql
    printf "             from sys.dba_sys_privs\n" >> upd_apex.sql
    printf "             where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' ) loop\n" >> upd_apex.sql
    printf "        execute immediate 'grant '||c1.privilege||' to ${schema} with admin option';\n" >> upd_apex.sql
    printf "    end loop;\n" >> upd_apex.sql
    printf "commit;\n" >> upd_apex.sql
    printf "end;\n/\n\n" >> upd_apex.sql
    printf "begin\n" >> upd_apex.sql
    printf "    apex_instance_admin.add_workspace(\n" >> upd_apex.sql
    printf "       p_workspace_id   => null,\n" >> upd_apex.sql
    printf "       p_workspace      => '${wsname}',\n" >> upd_apex.sql
    printf "       p_primary_schema => '${schema}'\n" >> upd_apex.sql
    printf "     );\n" >> upd_apex.sql
    printf "     commit;\n" >> upd_apex.sql
    printf "end;\n/\n\n" >> upd_apex.sql
    printf "conn ${schema}/${pwd}@${conn}\n\n" >> upd_apex.sql
    printf "begin\n" >> upd_apex.sql
    printf "    apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => '${schema}'));\n" >> upd_apex.sql
    printf "    apex_util.create_user(\n" >> upd_apex.sql
    printf "        p_user_name               => '${schema}',\n" >> upd_apex.sql
    printf "        p_email_address           => 'dummy@oracle.com',\n" >> upd_apex.sql
    printf "        p_default_schema          => '${schema}',\n" >> upd_apex.sql
    printf "        p_allow_access_to_schemas => '${schema}',\n" >> upd_apex.sql
    printf "        p_web_password            => '${pwd}',\n" >> upd_apex.sql
    printf "        p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',\n" >> upd_apex.sql
    printf "        p_allow_app_building_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_sql_workshop_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_websheet_dev_yn   => 'y',\n" >> upd_apex.sql
    printf "        p_allow_team_development_yn   => 'y'\n" >> upd_apex.sql
    printf "    );\n" >> upd_apex.sql
    printf "    commit;\n" >> upd_apex.sql
    printf "end;\n/\nexit\n" >> upd_apex.sql
    ./sqlcl/bin/sql /nolog @./upd_apex.sql
fi

if [ -n "${application_id}" ]; then
    if [ -f "f${application_id}.xml" ]; then
        echo "Copying application ${application_id} to ${schema}."
        printf "declare\nl_workspace_id number;\nbegin\n" > upd_apex_privs.sql;
        printf "l_workspace_id := apex_util.find_security_group_id (p_workspace => '${wsname}');\n" >> upd_apex_privs.sql;
        printf "apex_util.set_security_group_id (p_security_group_id => l_workspace_id);\n" >> upd_apex_privs.sql;
        printf "APEX_UTIL.PAUSE(2);\n" >> upd_apex_privs.sql;
        printf "end;\n/\n" >> upd_apex_privs.sql;

        printf "set cloudconfig ./network/admin/wallet.zip\nconn ${schema}/${pwd}@${conn}\n@upd_apex_privs.sql\nlb update -changelog f${application_id}.xml\nexit" > upd_apex.sql
        
        ./sqlcl/bin/sql /nolog @./upd_apex.sql
    else
        echo "${application_id} not found. Not copied to Dev${task_id} ${schema}."
    fi
fi
