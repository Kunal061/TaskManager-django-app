# Django Task Manager - Architecture Documentation

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Browser │  │  Mobile  │  │  Tablet  │  │    API   │   │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘   │
└────────┼─────────────┼─────────────┼─────────────┼─────────┘
         │             │             │             │
         └─────────────┴─────────────┴─────────────┘
                        │
                   Port 9000
                        │
         ┌──────────────▼──────────────┐
         │      NGINX (Optional)       │
         │    Reverse Proxy + SSL      │
         └──────────────┬──────────────┘
                        │
         ┌──────────────▼──────────────┐
         │     DOCKER CONTAINER        │
         │  ┌───────────────────────┐  │
         │  │   Gunicorn WSGI       │  │
         │  │   (3 Workers)         │  │
         │  └──────────┬────────────┘  │
         │             │                │
         │  ┌──────────▼────────────┐  │
         │  │   Django Application  │  │
         │  │   - URL Routing       │  │
         │  │   - Views             │  │
         │  │   - Models            │  │
         │  │   - Templates         │  │
         │  │   - Static Files      │  │
         │  └──────────┬────────────┘  │
         └─────────────┼────────────────┘
                       │
         ┌─────────────▼────────────┐
         │  DOCKER CONTAINER        │
         │  ┌────────────────────┐  │
         │  │  PostgreSQL 15     │  │
         │  │  Database          │  │
         │  └────────────────────┘  │
         └──────────────────────────┘
```

## Component Architecture

### Docker Compose Stack

```
┌─────────────────────────────────────────────────────┐
│                 Docker Compose                      │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │           WEB SERVICE (Django)               │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  FROM: python:3.11-slim              │  │  │
│  │  │  WORKDIR: /app                        │  │  │
│  │  │  PORT: 9000                           │  │  │
│  │  │  ┌────────────────────────────────┐   │  │  │
│  │  │  │  Application Code              │   │  │  │
│  │  │  │  - taskmanager/                │   │  │  │
│  │  │  │  - tasks/                      │   │  │  │
│  │  │  │  - templates/                  │   │  │  │
│  │  │  │  - static/                     │   │  │  │
│  │  │  └────────────────────────────────┘   │  │  │
│  │  │  ┌────────────────────────────────┐   │  │  │
│  │  │  │  Dependencies                  │   │  │  │
│  │  │  │  - Django 4.2.7                │   │  │  │
│  │  │  │  - Gunicorn 21.2               │   │  │  │
│  │  │  │  - psycopg2-binary             │   │  │  │
│  │  │  │  - WhiteNoise                  │   │  │  │
│  │  │  └────────────────────────────────┘   │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
│                      ▲                             │
│                      │ Depends On                  │
│                      ▼                             │
│  ┌──────────────────────────────────────────────┐  │
│  │           DB SERVICE (PostgreSQL)            │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  FROM: postgres:15-alpine            │  │  │
│  │  │  PORT: 5432 (internal)               │  │  │
│  │  │  VOLUME: postgres_data               │  │  │
│  │  │  ┌────────────────────────────────┐   │  │  │
│  │  │  │  Database Configuration        │   │  │  │
│  │  │  │  - DB: taskmanager_db          │   │  │  │
│  │  │  │  - User: taskmanager_user      │   │  │  │
│  │  │  │  - Password: from .env         │   │  │  │
│  │  │  └────────────────────────────────┘   │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
│                                                     │
│  ┌──────────────────────────────────────────────┐  │
│  │              VOLUMES                         │  │
│  │  - postgres_data (Database persistence)     │  │
│  │  - static_volume (Static files)             │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Django Application Architecture

### MVC Pattern (Model-View-Controller)

```
┌────────────────────────────────────────────────────┐
│                  DJANGO MVT PATTERN                │
│                                                    │
│  ┌──────────────┐         ┌──────────────┐       │
│  │   MODELS     │◄────────┤     ORM      │       │
│  │  (models.py) │         └──────────────┘       │
│  │              │                 │               │
│  │  - Task      │                 ▼               │
│  │    - title   │         ┌──────────────┐       │
│  │    - desc    │         │  PostgreSQL  │       │
│  │    - priority│         │   Database   │       │
│  │    - status  │         └──────────────┘       │
│  │    - due_date│                                 │
│  └──────┬───────┘                                 │
│         │                                         │
│         ▼                                         │
│  ┌──────────────┐         ┌──────────────┐       │
│  │    VIEWS     │────────►│   TEMPLATES  │       │
│  │  (views.py)  │         │   (HTML)     │       │
│  │              │         │              │       │
│  │ - ListView   │         │ - base.html  │       │
│  │ - CreateView │         │ - task_list  │       │
│  │ - UpdateView │         │ - task_form  │       │
│  │ - DeleteView │         │ - task_delete│       │
│  └──────▲───────┘         └──────────────┘       │
│         │                                         │
│         │                                         │
│  ┌──────┴───────┐         ┌──────────────┐       │
│  │     URLS     │         │    FORMS     │       │
│  │  (urls.py)   │         │  (forms.py)  │       │
│  │              │         │              │       │
│  │ - /          │         │ - TaskForm   │       │
│  │ - /task/new/ │         │   - title    │       │
│  │ - /task/edit/│         │   - priority │       │
│  │ - /task/del/ │         │   - status   │       │
│  └──────────────┘         └──────────────┘       │
└────────────────────────────────────────────────────┘
```

## Request Flow

```
1. User Request
   ├─► Browser sends HTTP request to http://server:9000/
   │
2. Docker Network
   ├─► Request reaches Docker container on port 9000
   │
3. Gunicorn WSGI Server
   ├─► Gunicorn receives request
   ├─► Distributes to one of 3 workers
   │
4. Django Application
   ├─► URL Router (urls.py) matches path
   │   └─► '' → tasks.urls.task_list
   │
   ├─► View (views.py)
   │   └─► TaskListView.as_view()
   │       ├─► Query database via ORM
   │       ├─► Apply filters (status, priority)
   │       └─► Paginate results
   │
   ├─► Model (models.py)
   │   └─► Task.objects.all()
   │       └─► SQL Query to PostgreSQL
   │
   ├─► Database
   │   └─► PostgreSQL executes query
   │       └─► Returns QuerySet
   │
   ├─► Template (task_list.html)
   │   ├─► Extends base.html
   │   ├─► Renders task cards
   │   └─► Applies Bootstrap styling
   │
5. Response
   └─► HTML sent back through Gunicorn
       └─► Browser renders page
```

## Data Flow Diagram

```
┌──────────────────────────────────────────────────┐
│                 CREATE TASK                      │
└──────────────────────────────────────────────────┘

User
 │
 ├─► GET /task/new/
 │   └─► TaskCreateView
 │       └─► Render task_form.html with empty form
 │           └─► Display to user
 │
 └─► POST /task/new/
     └─► TaskCreateView
         ├─► Validate TaskForm
         │   ├─► Check required fields
         │   └─► Validate data types
         ├─► form.save()
         │   └─► Task.objects.create(...)
         │       └─► INSERT INTO tasks_task
         │           └─► PostgreSQL saves data
         └─► Redirect to task_list
             └─► Show success message

┌──────────────────────────────────────────────────┐
│                 UPDATE TASK                      │
└──────────────────────────────────────────────────┘

User
 │
 ├─► GET /task/123/edit/
 │   └─► TaskUpdateView
 │       ├─► Task.objects.get(pk=123)
 │       │   └─► SELECT * FROM tasks_task WHERE id=123
 │       └─► Render task_form.html with filled form
 │
 └─► POST /task/123/edit/
     └─► TaskUpdateView
         ├─► Validate form
         ├─► form.save()
         │   └─► UPDATE tasks_task SET ... WHERE id=123
         └─► Redirect to task_list

┌──────────────────────────────────────────────────┐
│                 DELETE TASK                      │
└──────────────────────────────────────────────────┘

User
 │
 ├─► GET /task/123/delete/
 │   └─► TaskDeleteView
 │       └─► Render confirmation page
 │
 └─► POST /task/123/delete/
     └─► TaskDeleteView
         ├─► Task.objects.get(pk=123).delete()
         │   └─► DELETE FROM tasks_task WHERE id=123
         └─► Redirect to task_list
```

## Database Schema

```
┌─────────────────────────────────────────┐
│         tasks_task TABLE                │
├─────────────────────────────────────────┤
│ id              │ SERIAL PRIMARY KEY    │
│ title           │ VARCHAR(200) NOT NULL │
│ description     │ TEXT                  │
│ priority        │ VARCHAR(10)           │
│                 │   [low/medium/high]   │
│ status          │ VARCHAR(20)           │
│                 │   [pending/in_        │
│                 │    progress/completed]│
│ due_date        │ DATE NULL             │
│ created_at      │ TIMESTAMP             │
│ updated_at      │ TIMESTAMP             │
│ user_id         │ INT FOREIGN KEY       │
└─────────────────────────────────────────┘
         │
         │ Foreign Key
         ▼
┌─────────────────────────────────────────┐
│         auth_user TABLE                 │
├─────────────────────────────────────────┤
│ id              │ SERIAL PRIMARY KEY    │
│ username        │ VARCHAR(150) UNIQUE   │
│ email           │ VARCHAR(254)          │
│ password        │ VARCHAR(128)          │
│ first_name      │ VARCHAR(150)          │
│ last_name       │ VARCHAR(150)          │
│ is_staff        │ BOOLEAN               │
│ is_active       │ BOOLEAN               │
│ date_joined     │ TIMESTAMP             │
└─────────────────────────────────────────┘
```

## Technology Stack Layers

```
┌──────────────────────────────────────────────┐
│           PRESENTATION LAYER                 │
│  ┌────────────────────────────────────────┐  │
│  │  HTML5 + CSS3 + JavaScript             │  │
│  │  - Bootstrap 5.3.2                     │  │
│  │  - Bootstrap Icons                     │  │
│  │  - Custom CSS (Gradients, Animations)  │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
                    ▲
                    │
┌──────────────────────────────────────────────┐
│           APPLICATION LAYER                  │
│  ┌────────────────────────────────────────┐  │
│  │  Django 4.2.7                          │  │
│  │  - MVT Architecture                    │  │
│  │  - Class-based Views                   │  │
│  │  - Django ORM                          │  │
│  │  - Template Engine                     │  │
│  │  - Form Handling                       │  │
│  │  - Admin Interface                     │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
                    ▲
                    │
┌──────────────────────────────────────────────┐
│              DATA LAYER                      │
│  ┌────────────────────────────────────────┐  │
│  │  PostgreSQL 15                         │  │
│  │  - Relational Database                 │  │
│  │  - ACID Compliance                     │  │
│  │  - Connection Pooling                  │  │
│  │  - Full-text Search                    │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
                    ▲
                    │
┌──────────────────────────────────────────────┐
│           INFRASTRUCTURE LAYER               │
│  ┌────────────────────────────────────────┐  │
│  │  Docker + Docker Compose               │  │
│  │  - Container Orchestration             │  │
│  │  - Network Isolation                   │  │
│  │  - Volume Management                   │  │
│  │  - Service Dependencies                │  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │  Gunicorn WSGI Server                  │  │
│  │  - 3 Worker Processes                  │  │
│  │  - Process Management                  │  │
│  │  - Load Distribution                   │  │
│  └────────────────────────────────────────┘  │
│  ┌────────────────────────────────────────┐  │
│  │  WhiteNoise                            │  │
│  │  - Static File Serving                 │  │
│  │  - Compression                         │  │
│  │  - Caching Headers                     │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

## Deployment Architecture (EC2)

```
┌────────────────────────────────────────────────┐
│              AWS CLOUD (EC2)                   │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │        EC2 Instance                      │ │
│  │  ┌────────────────────────────────────┐  │ │
│  │  │     Security Group                 │  │ │
│  │  │  - Inbound: 22 (SSH)              │  │ │
│  │  │  - Inbound: 9000 (App)            │  │ │
│  │  │  - Outbound: All                  │  │ │
│  │  └────────────────────────────────────┘  │ │
│  │                                          │ │
│  │  ┌────────────────────────────────────┐  │ │
│  │  │  Amazon Linux 2023 / Ubuntu        │  │ │
│  │  │  ┌──────────────────────────────┐  │  │ │
│  │  │  │  Docker Engine               │  │  │ │
│  │  │  │  ┌────────────────────────┐  │  │  │ │
│  │  │  │  │ Docker Compose        │  │  │  │ │
│  │  │  │  │  - Web Container      │  │  │  │ │
│  │  │  │  │  - DB Container       │  │  │  │ │
│  │  │  │  └────────────────────────┘  │  │  │ │
│  │  │  └──────────────────────────────┘  │  │ │
│  │  └────────────────────────────────────┘  │ │
│  │                                          │ │
│  │  ┌────────────────────────────────────┐  │ │
│  │  │  EBS Volume (Storage)              │  │ │
│  │  │  - OS Files                        │  │ │
│  │  │  - Application Code                │  │ │
│  │  │  - Docker Volumes                  │  │ │
│  │  └────────────────────────────────────┘  │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │        Elastic IP (Optional)             │ │
│  │        - Static Public IP                │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                    ▲
                    │ HTTP
                    │
            ┌───────┴────────┐
            │     Users      │
            │   (Internet)   │
            └────────────────┘
```

## Security Architecture

```
┌──────────────────────────────────────────┐
│          SECURITY LAYERS                 │
├──────────────────────────────────────────┤
│                                          │
│  1. NETWORK SECURITY                     │
│     ├─► EC2 Security Groups              │
│     ├─► VPC Isolation (optional)         │
│     └─► SSL/TLS (recommended)            │
│                                          │
│  2. APPLICATION SECURITY                 │
│     ├─► Django Security Middleware       │
│     ├─► CSRF Protection                  │
│     ├─► XSS Protection                   │
│     ├─► SQL Injection Protection (ORM)   │
│     └─► Clickjacking Protection          │
│                                          │
│  3. AUTHENTICATION                       │
│     ├─► Django Admin Authentication      │
│     ├─► Password Hashing (PBKDF2)        │
│     └─► Session Management               │
│                                          │
│  4. CONFIGURATION SECURITY               │
│     ├─► Environment Variables (.env)     │
│     ├─► Secret Key Management            │
│     ├─► Debug Mode Control               │
│     └─► ALLOWED_HOSTS Restriction        │
│                                          │
│  5. DATABASE SECURITY                    │
│     ├─► PostgreSQL Authentication        │
│     ├─► Network Isolation (Docker)       │
│     └─► Encrypted Connections            │
│                                          │
│  6. CONTAINER SECURITY                   │
│     ├─► Docker Image Scanning            │
│     ├─► Minimal Base Images              │
│     └─► User Permissions                 │
│                                          │
└──────────────────────────────────────────┘
```

## Scalability Considerations

```
┌──────────────────────────────────────────┐
│        CURRENT ARCHITECTURE              │
│  Single EC2 Instance                     │
│  - 1 Docker Host                         │
│  - 3 Gunicorn Workers                    │
│  - PostgreSQL in Container               │
└──────────────────────────────────────────┘
                  │
                  ▼
┌──────────────────────────────────────────┐
│        SCALING OPTIONS                   │
├──────────────────────────────────────────┤
│                                          │
│  VERTICAL SCALING                        │
│  ├─► Larger EC2 Instance Type            │
│  ├─► More Gunicorn Workers               │
│  └─► Increased Database Resources        │
│                                          │
│  HORIZONTAL SCALING                      │
│  ├─► Multiple EC2 Instances              │
│  ├─► Load Balancer (ALB/ELB)             │
│  ├─► AWS RDS for PostgreSQL              │
│  ├─► Amazon ElastiCache (Redis)          │
│  └─► S3 for Static/Media Files           │
│                                          │
│  ADVANCED SCALING                        │
│  ├─► Kubernetes/ECS                      │
│  ├─► Auto Scaling Groups                 │
│  ├─► CDN (CloudFront)                    │
│  └─► Database Read Replicas              │
│                                          │
└──────────────────────────────────────────┘
```

---

**Documentation Version:** 1.0  
**Last Updated:** 2025-10-24
