#Portworx fix
dir=/sys/class/block/
jvmopts=/opt/dse/resources/cassandra/conf/jvm.options

for i in `ls -1 $dir | grep pxd\!`; do
  pre=`echo $i | awk -F\! '{print $1}'`
  post=`echo $i | awk -F\! '{print $2}'`
  echo -Ddse.io.$pre/$post.sector.size=4096 >> $jvmopts
done
