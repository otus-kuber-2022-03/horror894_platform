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
