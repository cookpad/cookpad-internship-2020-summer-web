// hako はアプリケーションの定義を書くために Jsonnet というテンプレート言語を採用しています。
// Jsonnet https://jsonnet.org/
// Jsonnetの薦め: https://qiita.com/yugui/items/f4a5e0e9dbd8ddffa48e

local totalCpu = 512;
local totalMemory = 1024;

local nginxCpu = 32;
local nginxMemory = 64;

local appCpu = totalCpu - nginxCpu;
local appMemory = totalMemory - nginxMemory;

local appPort = '3000';

local fileProvider = std.native('provide.file');
local provide(name) = fileProvider(std.toString({ path: 'hako.env' }), name);

local appId = std.extVar('appId');
local identifier = std.strReplace(appId, '-production', '');

local tinypad = import './tinypad.libsonnet';

{
  scheduler: {
    type: 'ecs',
    region: 'ap-northeast-1',
    cluster: 'hako-fargate',
    // IAM role used when staring containers
    // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
    execution_role_arn: provide('execution_role_arn'),
    // IAM role used inside a container (i.e., used by your application)
    // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html
    task_role_arn: provide('task_role_arn'),
    // The number of tasks
    desired_count: 2,
    // launch_type and requires_compatibilities fields are required to launch tasks in Fargate
    launch_type: 'FARGATE',
    requires_compatibilities: ['FARGATE'],
    // Available Fargate resources: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-tasks-size
    cpu: std.toString(totalCpu),
    memory: std.toString(totalMemory),
    // In Fargate, each task has each private IP and security group.
    network_mode: 'awsvpc',
    network_configuration: {
      awsvpc_configuration: {
        security_groups: [provide('ecs_service_sg')],
        subnets: [provide('subnet_c_private'), provide('subnet_d_private')],
      },
    },
    // https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/introduction.html
    elb_v2: {
      scheme: 'internet-facing',
      vpc_id: provide('vpc_id'),
      subnets: [provide('subnet_c_public'), provide('subnet_d_public')],  // public subnets
      security_groups: [provide('http_open_sg')],
      health_check_path: '/',
      listeners: [{ port: 80, protocol: 'HTTP' }],
      load_balancer_attributes: {
        'idle_timeout.timeout_seconds': '30',
      },
      target_group_attributes: {
        // Configure deregistration delay for faster deployment
        // https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html#deregistration-delay
        'deregistration_delay.timeout_seconds': '20',
      },
    },
  },
  app: tinypad.appContainer(appCpu, appMemory, identifier) {
    env+: {
      DATABASE_URL: tinypad.databaseUrl(identifier, identifier + '_production'),
      SECRET_KEY_BASE: provide('secret_key_base_production'),
    },
  },
  additional_containers: {
    front: tinypad.frontContainer(nginxCpu, nginxMemory),
  },
  scripts: [
    {
      // Create CloudWatch log group automatically
      type: 'create_aws_cloud_watch_logs_log_group',
    },
    {
      type: 'nginx_front',
      // Proxy HTTP requests to app container's port
      backend_port: appPort,
      locations: {
        '/': {
          https_type: 'null',
        },
      },
      // nginx configuration is saved to s3://cookpad-internship/common/hako/front_config/
      s3: {
        region: 'ap-northeast-1',
        bucket: 'cookpad-internship',
        prefix: 'common/hako/front_config',
      },
    },
  ],
}
