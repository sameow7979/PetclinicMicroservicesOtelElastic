
The project has been complied. Execute the script by running ./scripts/run_all.sh under the project root. 

To change the elastic endpoint configuration, edit the endpoint and authorization configuration in /scripts/run_all.sh
-Dotel.exporter.otlp.endpoint="https://xxxxxxxx.apm.ap-southeast-1.aws.cloud.es.io:443" \
-Dotel.exporter.otlp.headers="Authorization=Bearer xxxxxxxxxxx" \
