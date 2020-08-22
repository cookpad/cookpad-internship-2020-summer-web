local appId = std.extVar('appId');

local fileProvider = std.native('provide.file');
local provide(name) = fileProvider(std.toString({ path: 'hako.env' }), name);

// Send container logs to CloudWatch Logs
// You can see logs from: https://ap-northeast-1.console.aws.amazon.com/ecs/home?region=ap-northeast-1#/clusters/hako-fargate/services/<service name>/logs
local logConfiguration(appId) = {
  log_driver: 'awslogs',
  options: {
    'awslogs-group': std.format('/ecs/hako/%s', appId),
    'awslogs-region': 'ap-northeast-1',
    'awslogs-stream-prefix': 'ecs',
  },
};

{
  appContainer(appCpu, appMemory, appImageName):: {
    image: std.format('%(account_id)s.dkr.ecr.ap-northeast-1.amazonaws.com/%(appImageName)s', { account_id: provide('account_id'), appImageName: appImageName }),
    cpu: appCpu,
    memory: appMemory,
    log_configuration: logConfiguration(appId),
    env: {
      RAILS_ENV: 'production',
      RAILS_LOG_TO_STDOUT: '1',
      DATABASE_PASSWORD: provide('mysql_password'),
      SECRET_KEY_BASE: provide('secret_key_base'),
    },
  },
  frontContainer(cpu, memory):: {
    cpu: cpu,
    memory: memory,
    image_tag: std.format('%s.dkr.ecr.ap-northeast-1.amazonaws.com/hako-nginx:latest', provide('account_id')),
    log_configuration: logConfiguration(appId),
  },
  databaseUrl(user, database)::
    std.format('mysql2://%(user)s@summer-internship-2020.cluster-cc7xfhp2kekk.ap-northeast-1.rds.amazonaws.com:3306/%(database)s?encoding=utf8mb4&collation=utf8mb4_bin', { user: user, database: database }),
}
