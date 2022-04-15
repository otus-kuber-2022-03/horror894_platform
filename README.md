# horror894_platform
horror894 Platform repository

<details>
<summary> <b>HW №1 Kubernetes-intro</b> </summary>
=========================================

PODs: **kube-apiserver**, **kube-controller-manager**, **etcd-kube**, **kube-scheduler** are static pods that are not conrolled by k8s. Path to manifests for this pods set in kubelet conf. 
When we delete this pods using kubectl nothing happend.
When we delete containers, restoration triggered by probes set for this pods. 

PODs: **proxy** and **coredns** controlled by controller-manager. DaemonSet and ReplicaSet respectively.

What was done:
1. Created **kubernetes-intro/web/Dockerfile**. With python3 simple http. Image pushed to DockerHub - **horror894/intro-http:1.0**
2. Created **kubernetes-intro/web-pod.yaml**. Manifest include our image with http service and init container that create index.html page. To provide accesto the index.html file we use pod volume.  
3. Created docker image based on Dockerfile from [repo](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/src/frontend/Dockerfile) and pushed to DockerHub.
4. Using ad-hoc mode created **kubernetes-intro/frontend-pod.yaml**. 
5. After apply **kubernetes-intro/frontend-pod.yaml** pod has status Error.
6. Exec command "kubectl logs frontend" we saw that environment variabls not set.
6. Created new manifest **kubernetes-intro/frontend-pod-healthy.yaml** added variables from [repo](https://github.com/GoogleCloudPlatform/microservices-demo/blob/master/release/kubernetes-manifests.yaml). POD frontend in status "Running".
</details>

<details>
<summary> <b>HW №2 Kubernetes-controllers</b> </summary>
=========================================

* ***Why applying manifest **kubernetes-controllers/frontend-replicaset.yaml** with new ver. of app. didn't update running pods:***
Replicaset does not check that pods have a right template, replicaset controller filtered pods base on rs referens and selectors.
Than we compare count of received pods and count of replicas in configuration.

[Source](https://github.com/kubernetes/kubernetes/blob/master/pkg/controller/replicaset/replica_set.go): 
```Go
diff := len(filteredPods) - int(*(rs.Spec.Replicas))
if diff < 0 
```

* ***How DaemonSet could be applied to master nodes:***
K8s has mechanism [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
We have some system taints, in our case it's **node-role.kubernetes.io/master**. 
If we want run our DaemonSet on master node, we need to add toleration for that taint. 

What was done:
1. Created manifest **kubernetes-controllers/frontend-replicaset.yaml**, for deploy pods using replica set.
2. Template that we use for creating **kubernetes-controllers/frontend-replicaset.yaml** contain error, it missed section selector. Fixed.
3. Create two docker images and push them into docker **horror894/controllers-hipster-shop-paymentservice** tag v0.0.1 and v0.0.2
4. Create **kubernetes-controllers/paymentservice-replicaset.yaml**, replica count 3 app=v0.0.1. Apply it.
5. Create **kubernetes-controllers/paymentservice-deployment.yaml**, replica count 3 app=v.0.0.1 . Apply it.
6. Set app=v0.0.2 in **kubernetes-controllers/paymentservice-deployment.yaml** and apply it.
7. Made rollback using kubectl rollout undo.
8. Created **kubernetes-controllers/paymentservice-deployment-bg.yaml** for blue-green deployment and **kubernetes-controllers/paymentservice-deployment-reverse.yaml** for reverse rolling.
9. Created **kubernetes-controllers/frontend-deployment.yaml**, replica count 3 app=v0.0.1 and added description for readinessProbe.
10. Create **kubernetes-controllers/nodeexporter-daemonset.yaml** and check that we could receive metrics. 

</details>


<details>
<summary> <b>HW №3 Kubernetes-security</b> </summary>
=========================================

What was done:
1. Prepared manifests for creating required resources: user, namespace, clusterrole, role, bindings.
2. I checked rights of service accounts using "auth can-i" 

```Go
kubectl auth can-i <verb> <resource> --as=system:serviceaccount:<namespace>:<serviceaccountname> [-n <namespace>]
```

</details>
