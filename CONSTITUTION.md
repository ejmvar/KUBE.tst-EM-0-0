
# Objectives:

Design the simplest kubernetes infrastrucure.
Ensure migration to new version (rollout, rollback)
Ensure proper scaling
Ensure observability
Verify namespace isolation
Verify inter-communication between services, clients, storage.


Ensure all basic services available from the very beginning [Services](./Services to implement).


# Tooling: from simplest environment to high availability
Start using :
- kind (start simple on-premise, plan for minikube, suggest alternative for huge clients, AWS, GCP, Azure)
- kubernetes
Gradually add:
- gateway-api (envoy, suggest others)
- loadbalancer (keda, review metaLB, research for alternatives: simpler, faster, wider applicability)

- devcontainer: plan for isolation

- plan for other kubernetes tooling


# Services to implement
these are the steps to enhance, step by step, so to verify every available service and interaction.
every stage of development must add testing (TDD always)

## Initial:
- backend: python (start minimal)
## add frontend
- frontend: react (start minimal)
## add database
- postgres for backend:
  -- read the smallest table
  -- return a value to backend
  -- expose in /api/testpg
## add secrets:
- spc name (space name to retain isolated environments)
- env name 
- rls name 
- client name 

## add block storage:
- ensure isolation between env ironments
- ensure backup facility 
- ensure recoverability


## add object storage: rustfs (s3 compatible)
- same as block storage

# Structure:



