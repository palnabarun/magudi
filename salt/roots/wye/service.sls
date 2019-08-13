{% set name = pillar['service']['name'] %}

{{pillar[name]["media_root"]}}:
  file.directory:
    - user: app
    - makedirs: True

/etc/init/{{name}}.conf:
  file.managed:
    - source: salt://{{name}}/files/{{name}}.conf.j2
    - user: app

{{name}}:
  service.running:
    - require:
      - file: /etc/init/{{name}}.conf
      - file: /etc/uwsgi/{{name}}.ini
      - file: {{pillar[name]["media_root"]}}
      - pip: uwsgi
      - cmd: /opt/envs/{{name}}/bin/python manage.py migrate
    - reload: True
    - watch:
      - file: /etc/init/{{name}}.conf
      - file: /etc/uwsgi/{{name}}.ini
      - file: /opt/{{name}}/settings/prod.py
      - git: {{name}}_code

/etc/nginx/sites-available/pythonexpress.org/express.conf:
  file.managed:
    - source: salt://{{name}}/files/express.conf.j2
    - require:
        - file: nginx_pythonexpress_dir
    - template: jinja

/etc/nginx/sites-available/pythonexpress.org/upstreams/{{name}}_upstream.conf:
  file.managed:
    - source: salt://{{name}}/files/{{name}}_upstream.conf.j2
    - require:
        - file: nginx_pythonexpress_dir
    - template: jinja
    - defaults:
      http_port: {{pillar[name]['server_config']['port']}}
