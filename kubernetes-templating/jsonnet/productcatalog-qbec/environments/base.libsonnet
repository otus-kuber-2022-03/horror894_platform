{
  components: {
    productcatalog: {
      name: "productcatalogservice",
      image: "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.1.3",
      replicas: 1,
      containerPort: 3550,
      servicePort: 3550,
      containerPortName: "PORT",
      serviceType: "ClusterIP",
      requests: {
        cpu: "100m", 
        memory: "65Mi",
      },
      limits: {
        cpu: "200m",
        memory: "128Mi",
      },
    },
  },
}
