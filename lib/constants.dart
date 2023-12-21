const mode = String.fromEnvironment('mode', defaultValue: 'dev');
const isProduction = mode == 'prod';
const isDevelopment = mode == 'dev';
const isStaging = mode == 'staging';
