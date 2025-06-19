-- Create the development database if it doesn't exist
SELECT 'CREATE DATABASE niufoods_monitor_v1_development'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'niufoods_monitor_v1_development')\gexec

-- Create the test database if it doesn't exist
SELECT 'CREATE DATABASE niufoods_monitor_v1_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'niufoods_monitor_v1_test')\gexec

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON DATABASE niufoods_monitor_v1_development TO niufoods_user;
GRANT ALL PRIVILEGES ON DATABASE niufoods_monitor_v1_test TO niufoods_user; 