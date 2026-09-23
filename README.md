# komp

komp is a local-first cloud application platform for building, deploying, and operating containerized applications on Kubernetes.

The long-term goal is to create a small internal developer platform where a developer can point komp at a Git repository and get a running application without needing to interact directly with Docker, Kubernetes manifests, Services, or routing.

For v0.1, komp is intentionally narrow:

> Public Git repository with a Dockerfile → BuildKit image build → local registry → Kubernetes deployment → stable `*.localhost` URL.

The project is designed as a learning-heavy control plane, not as an AWS clone. The emphasis is on reconciliation, declarative APIs, immutable releases, build orchestration, runtime state, and progressively hiding infrastructure complexity behind useful platform abstractions.

---

## Vision

A future komp workflow should feel roughly like this:

```text
Developer
   |
   | Git repository
   v
+-------------------+
|      komp API     |
+---------+---------+
          |
          v
+-------------------+
|    Build Worker   |
| Git + BuildKit    |
+---------+---------+
          |
          v
+-------------------+
|  Container Image  |
|  Local/ECR Registry|
+---------+---------+
          |
          v
+-------------------+
|   komp Controller |
+---------+---------+
          |
          v
+-------------------------------+
|          Kubernetes           |
| Deployment / Service / Route  |
+---------------+---------------+
                |
                v
       https://app.example
```

komp should own the platform complexity so application developers can express intent instead of infrastructure details.

---

## v0.1 architecture

The first release focuses on one local Kubernetes cluster and one trusted developer.

```text
                +------------------+
                |   komp web UI    |
                +--------+---------+
                         |
                         v
                +------------------+
                |    komp API      |
                +--------+---------+
                         |
             +-----------+-----------+
             |                       |
             v                       v
      +-------------+         +-------------+
      | PostgreSQL  |         | Build Queue |
      +-------------+         +------+------+
                                     |
                                     v
                              +--------------+
                              | komp builder |
                              | Git/BuildKit |
                              +------+-------+
                                     |
                                     v
                              +--------------+
                              | Local registry|
                              +------+-------+
                                     |
                                     v
                              +------------------+
                              | NebulaService CR |
                              +--------+---------+
                                       |
                                       v
                              +------------------+
                              | komp controller  |
                              +--------+---------+
                                       |
                    +------------------+------------------+
                    |                  |                  |
                    v                  v                  v
              Deployment           Service           HTTPRoute
                    \__________________|__________________/
                                       |
                                       v
                                  Application
```

### Control-plane responsibilities

komp owns:

- application metadata
- source configuration
- build orchestration
- build logs
- immutable release history
- desired runtime configuration
- translation from platform intent into Kubernetes resources

Kubernetes owns:

- pods
- replica state
- scheduling
- workload health
- Service networking
- live routing state

PostgreSQL must not become a shadow copy of Kubernetes runtime state.

---

## Core platform resource

The first komp abstraction is a Kubernetes custom resource:

```yaml
apiVersion: platform.komp.dev/v1alpha1
kind: NebulaService

metadata:
  name: hello

spec:
  image: nginx:1.27
  port: 80
  replicas: 1
```

The komp controller continuously reconciles that desired state into Kubernetes resources such as:

- `Deployment`
- `Service`
- `HTTPRoute`

The first major architectural milestone is proving that the controller repairs drift and recreates deleted child resources.

---

## v0.1 scope

### Included

- Go control plane
- Kubebuilder / controller-runtime
- `NebulaService` CRD
- Deployment reconciliation
- Service reconciliation
- Gateway API routing
- Kubernetes-style readiness conditions
- local kind cluster
- public Git repositories
- Dockerfile builds
- BuildKit
- local container registry
- PostgreSQL-backed build queue
- exact Git commit pinning
- immutable image digests
- immutable release records
- REST API
- minimal React/TypeScript dashboard
- build logs
- current pod logs
- local end-to-end CI

### Intentionally excluded from v0.1

- AWS
- Terraform
- EKS
- GitHub OAuth
- authentication / RBAC
- multi-user support
- private Git repositories
- autoscaling
- Kafka / NATS / RabbitMQ
- Argo CD
- Crossplane
- Prometheus / Grafana / Loki / Tempo
- OpenTelemetry
- TLS
- custom public domains
- preview environments
- multi-cluster support
- untrusted multi-tenant build execution

v0.1 should be treated as a trusted local-development platform.

---

## Roadmap

The roadmap is deliberately dependency-ordered. Each issue should end in a demonstrable behavior before the next layer is added.

### Phase 1: control-plane foundation

- [#1 Bootstrap the Go/Kubebuilder control-plane project](https://github.com/D3V-K/komp/issues/1)
- [#2 Define the NebulaService v1alpha1 custom resource](https://github.com/D3V-K/komp/issues/2)
- [#3 Reconcile NebulaService into a Kubernetes Deployment](https://github.com/D3V-K/komp/issues/3)
- [#4 Reconcile a Kubernetes Service for each NebulaService](https://github.com/D3V-K/komp/issues/4)
- [#5 Report runtime readiness through NebulaService status conditions](https://github.com/D3V-K/komp/issues/5)
- [#6 Expose NebulaService workloads through Gateway API](https://github.com/D3V-K/komp/issues/6)
- [#7 Add controller reconciliation and drift-repair tests](https://github.com/D3V-K/komp/issues/7)

At the end of this phase:

```text
NebulaService
      |
      v
komp controller
      |
      +--> Deployment
      +--> Service
      +--> HTTPRoute
               |
               v
       http://hello.localhost
```

### Phase 2: application and build model

- [#8 Introduce PostgreSQL persistence for applications, builds, and releases](https://github.com/D3V-K/komp/issues/8)
- [#9 Add REST API for applications and build requests](https://github.com/D3V-K/komp/issues/9)
- [#10 Implement a PostgreSQL-backed build worker queue](https://github.com/D3V-K/komp/issues/10)
- [#11 Clone public Git repositories and pin builds to exact commits](https://github.com/D3V-K/komp/issues/11)
- [#12 Build Dockerfile applications with BuildKit and push to a local registry](https://github.com/D3V-K/komp/issues/12)

At the end of this phase:

```text
Git repository
      |
      v
exact commit
      |
      v
BuildKit
      |
      v
immutable image digest
```

### Phase 3: source-to-runtime integration

- [#13 Create immutable releases and activate them through NebulaService](https://github.com/D3V-K/komp/issues/13)
- [#14 Expose build logs and application pod logs through the API](https://github.com/D3V-K/komp/issues/14)
- [#15 Build the minimal komp web dashboard](https://github.com/D3V-K/komp/issues/15)
- [#16 Automate local bootstrap and end-to-end v0.1 verification](https://github.com/D3V-K/komp/issues/16)

At the end of this phase:

```text
Git repository
      |
      v
Build
      |
      v
Release
      |
      v
NebulaService
      |
      v
Kubernetes
      |
      v
*.localhost URL
```

---

## v0.1 definition of done

komp v0.1 is complete when a developer can start from a clean local environment, provide a public Git repository containing a Dockerfile, trigger a deployment through komp, and receive a reachable local URL without manually interacting with Docker or Kubernetes.

The release should handle and demonstrate:

- successful first deployment
- deployment of a second commit
- failed Git clone
- failed Docker build
- container crash after deployment
- controller restart
- API restart
- manually deleted Deployment repaired by reconciliation
- application deletion
- clean local bootstrap
- automated end-to-end CI

---

## Development strategy

The project should be built in vertical slices rather than as a collection of disconnected infrastructure components.

The recommended first checkpoints are:

```text
1. NebulaService exists
       |
2. NebulaService creates Deployment
       |
3. controller repairs deleted Deployment
       |
4. NebulaService creates Service
       |
5. workload becomes reachable through Gateway API
       |
6. Git repository becomes an image digest
       |
7. image digest becomes an immutable release
       |
8. release becomes a running application
       |
9. browser can drive the entire flow
```

The first useful development target is intentionally tiny:

```text
NebulaService
      |
      v
Go controller
      |
      +--> Deployment
      +--> Service
      |
      v
nginx
```

Once reconciliation is solid, routing and build orchestration can be layered on top.

---

## Design principles

### Declarative over imperative

Users describe desired application state. komp reconciles reality toward it.

### Kubernetes is the runtime source of truth

Runtime health should be derived from Kubernetes, not duplicated into PostgreSQL.

### Immutable releases

Branches and tags are mutable. Releases should pin exact Git commits and exact container image digests.

### Idempotent reconciliation

Running the controller once or ten thousand times should converge on the same desired state.

### Infrastructure must earn its place

v0.1 intentionally avoids Kafka, Argo CD, Crossplane, and a full observability stack. Those technologies should be introduced only when the existing design creates a real need.

### Build the abstraction, not another YAML generator

The goal is to create a useful platform API that hides Kubernetes details, not simply move Kubernetes YAML behind an HTTP endpoint.

---

## Longer-term direction

After v0.1, likely areas of exploration include:

### v0.2+
- rollback support
- environment variables and secrets
- richer deployment status
- build cancellation
- build caching
- Cloud Native Buildpacks
- resource requests/limits
- health-check configuration

### v0.3+
- autoscaling
- KEDA
- OpenTelemetry
- Prometheus / Grafana
- structured application events
- canary or blue/green deployments

### Cloud milestone
- Terraform-managed AWS infrastructure
- EKS
- ECR
- RDS
- Route53
- IAM / workload identity
- managed ingress/load balancing

### Advanced platform capabilities
- GitOps / Argo CD
- Crossplane-managed infrastructure
- preview environments
- managed databases and queues
- policy enforcement
- quotas
- multi-cluster support
- supply-chain security
- SBOMs and image signing

A distributed exchange simulator is planned as a future reference workload to stress komp with multiple services, event-driven traffic, WebSockets, scaling, state, and failure scenarios.

---

## Why this project exists

komp is both a usable developer-platform experiment and a systems-engineering learning project.

The goal is to gain practical experience with:

- Go
- Kubernetes controllers
- CRDs
- reconciliation loops
- owner references
- status conditions
- Gateway API
- BuildKit
- container registries
- PostgreSQL concurrency
- asynchronous workers
- state machines
- immutable releases
- eventual consistency
- control-plane/data-plane separation
- CI and end-to-end platform testing

The architecture should evolve because real limitations are encountered, not because a diagram looks more impressive with additional boxes.
