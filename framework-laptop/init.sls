{% from "framework-laptop/map.jinja" import framework with context %}


include:
{% for state, params in framework.items() %}
  {% if params.include %}
  - .{{ params.include }}
  {% endif %}
{% endfor %}
