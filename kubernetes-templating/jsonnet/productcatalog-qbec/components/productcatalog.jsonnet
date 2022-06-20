local env = {
  name: std.extVar('qbec.io/env'),
  namespace: std.extVar('qbec.io/defaultNs'),
};
local p = import '../params.libsonnet';
local params = p.components.productcatalog;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: params.name,
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: { app: params.name },
        },
        spec: {
          containers: [
            {
              name: 'server',
              image: params.image,
              ports: [
                {
                  containerPort: params.containerPort,
                },
              ],
              env: [
                {
                  name: params.containerPortName,
                  value: '%s' % params.containerPort,
              },
              ],
              readinessProbe: {
                exec: {
                  command: [
                    "/bin/grpc_health_probe",
                    "-addr=:3550",
                  ],
                },
              },
              livenessProbe: {
                exec: {
                  command: [
                    "/bin/grpc_health_probe",
                    "-addr=:3550",
                  ],
                },
              },
              resources: {
                requests: {
                  cpu: params.requests.cpu,
                  memory: params.requests.memory
                },
                limits: {
                  cpu: params.limits.cpu,
                  memory: params.limits.memory,
                },
              },
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: params.name,
    },
    spec: {
      type: params.serviceType,
      selector: {
        app: params.name,
      },
      ports: [
        {
          portname: "grpc",
          port: params.servicePort,
          targetPort: params.containerPort,
        },
      ],
    },
  }
]
