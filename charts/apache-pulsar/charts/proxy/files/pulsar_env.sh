{{- $extraOpts := default list .Values.pulsarEnv.extraOpts -}}

PULSAR_EXTRA_CLASSPATH={{ join ";" .Values.pulsarEnv.extraClasspath | quote }}
PULSAR_EXTRA_OPTS={{ join " " $extraOpts | quote }}
PULSAR_GC={{ join " " .Values.pulsarEnv.gc | quote }}
PULSAR_MEM={{ join " " .Values.pulsarEnv.mem | quote }}
PULSAR_LOG_DIR=/pulsar/logs
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