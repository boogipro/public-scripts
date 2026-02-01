# startet die goaccess cli innerhalb des goaccess containers log format: NPM
cd /
cd /goaccess
./goaccess /opt/log/proxy-host-6_access.log /goaccess-logs/archives/proxy-host-6_access.log*  --time-format=%T   --date-format=%d/%b/%Y   --log-format='[%d:%t %^] %^ %^ %s - %m %^ %v \"%U\" [Client %h] [Length %b] [Gzip %^] [Senç^Cto %^
] \"%u\" \"%R\"'