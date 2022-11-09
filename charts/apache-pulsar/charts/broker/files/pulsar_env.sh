{{- $extraOpts := default list .Values.pulsarEnv.extraOpts -}}
{{ if eq (include "common.tls.require-secure-inter" $) "true" -}}
  {{- $extraOpts = concat $extraOpts (include "metadata-store.zookeeper.client" . | fromJsonArray)  -}}

# Clear out temp things & make a new temp
rm -rdf /pulsar/temp
mkdir /pulsar/temp
# Move the conf from readonly drive to local read drive
cp {{ printf "%s/%s" .Values.pulsarEnv.confPath "broker.conf" }} /pulsar/temp/broker.conf
# Replace placeholders with sensitive data
sed -i 's/((brokerClientTlsTrustStorePassword))/'$(cat /pulsar/jks/jks-password)'/g' /pulsar/temp/broker.conf
sed -i 's/((tlsKeyStorePassword))/'$(cat /pulsar/jks/jks-password)'/g' /pulsar/temp/broker.conf
sed -i 's/((tlsTrustStorePassword))/'$(cat /pulsar/jks/jks-password)'/g' /pulsar/temp/broker.conf
# Use the new conf
PULSAR_BROKER_CONF="/pulsar/temp/broker.conf"
{{ else }}
PULSAR_BROKER_CONF={{ printf "%s/%s" .Values.pulsarEnv.confPath "broker.conf" | quote }}

{{ end }}

PULSAR_EXTRA_CLASSPATH={{ join ";" .Values.pulsarEnv.extraClasspath | quote }}
PULSAR_EXTRA_OPTS={{ join " " $extraOpts | quote }}
PULSAR_GC={{ join " " .Values.pulsarEnv.gc | quote }}
PULSAR_MEM={{ join " " .Values.pulsarEnv.mem | quote }}
PULSAR_LOG_DIR={{ coalesce .Values.logPersistence.mountPath "/pulsar/logs" }}
PULSAR_STOP_TIMEOUT={{.Values.pulsarEnv.stopTimeout}}

# Garbage collection log.
IS_JAVA_8=`java -version 2>&1 |grep version|grep '"1\.8'`
# java version has space, use [[ -n $PARAM ]] to judge if variable exists
if [[ -n $IS_JAVA_8 ]]; then
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xloggc:/pulsar/logs/pulsar_gc_%p.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=20M"}
else
# After jdk 9, gc log param should config like this. Ignoring version less than jdk 8
  PULSAR_GC_LOG=${PULSAR_GC_LOG:-"-Xlog:gc*:/pulsar/logs/pulsar_gc_%p.log:time,uptime:filecount=10,filesize=20M"}
fi