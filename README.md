# hbase-standalone
running hbase without hdfs

# this deployment
This is a small-to-medium sized deployment of hbase **without** hadoop/hdfs.

It's a proof-of-concept to show that you can deploy a minimal hbase cluster like this.

Kubernetes configs in the `k8s/` directory will run a cluster of 1 hbase master and 2 regionserver nodes.

As you can tell from some of the DNS namespaces it was originally intended to be the backend for an OpenTSDB db.

# what, no hadoop/hdfs?
hbase needs a stable and reliable shared filesystem to cluster. **The shared filesystem does not need to be hdfs!**

If you have a reliable shared filesystem such as an NFS on Netapp, or Lustre, GPFS etc shared between your servers, you can create a hbase cluster without hadoop hdfs.

# what is included
The no-hdfs hbase deployment is described using Docker images.

The images expect to find each other by DNS names.

You might need to change them for your own needs:
* hmaster-0.hmaster.opentsdb.svc.cluster.local
* regionserver-0.regionserver.opentsdb.svc.cluster.local
* regionserver-1.regionserver.opentsdb.svc.cluster.local

# building
1. download hbase-1.2.6-bin.tar.gz (the most recent Stable version) from hbase into `bin/`
2. `docker build -t 'dehotot/hbase-standalone:latest' .`

# Running in Docker
## hbase cluster hmaster
`docker run -it dehotot/hbase-standalone:latest /start-hmaster.sh`

## hbase cluster regionserver node
`docker run -it dehotot/hbase-standalone:latest /start-regionserver.sh`

# Deploying in Kubernetes
You will need to build your own images from the dockerfiles provided.

Then you need:
* an `opentsdb` namespace
* a `PersistentVolume` and `PersistentVolumeClaim` called *metrics*

An example is provided in `k8s/example-namespace.yaml`

## to deploy on Kubernetes
1. edit and apply example-namespace.yaml to set up the namespace and your NFS share
2. deploy the hmaster: `kubectl apply -f k8s/hmaster.yaml`
3. deploy the regionservers: `kubectl apply -f k8s/regionservers.yaml`
4. watch the logs on the hmaster to see the nodes join: `kubectl logs -f hmaster0`
5. if you make the **hbase** Service accessible (we use an *externalIP* on our bare-metal, you might use a *LoadBalancer* in the cloud) then you can view the cluster status web gui here.

## scaling up
1. add the next logical worker to `conf/regionservers`
2. update the *replicas* value in `k8s/regionservers.yaml`
3. `apply` the new regionservers.yaml

## scaling down
1. i've not had to do it yet
2. you will need to tell hbase to remove one of its nodes before you scale down in k8s

## opentsdb namespace
This namespace is baked into the hbase cluster configuration, and therefore the Service entries.

If you want to use a different namespace, you need to change `conf/regionservers`, `conf/hbase-site.xml` and the `namespace` inside the k8s yamls.

# zookeeper
Because Kubernetes gives reliablily to the node roles, and we use this cluster to backend OpenTSDB, only one Zookeeper is needed for us.

We use the Zookeeper that comes prebuilt with hbase.


# intended purpose
The intended purpose is only to teach and demonstrate that you can run hbase without hdfs.

It's not intended for production. You need to evaluate the advice for your own purpose and make it usable for yourself.

No warranty is given or implied.

It is not advised to use it to run your local particle accelerator ;)
