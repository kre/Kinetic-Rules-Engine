
# Historical Note (301 - Permanent Redirect)

The code in this repository is no longer being maintained. We have rebuilt the rules engine as a Node.js application. The [new version of the engine is available from this repository](https://github.com/Picolab/pico-engine). 

The easiest way to get started with the new engine is to [use this Quickstart](https://picolabs.atlassian.net/wiki/spaces/docs/pages/19791878/Pico+Engine+Quickstart). 

# Kinetic Rules Engine (KRE)

The Kinetic Rules Engine (KRE), a open-source, cloud-based rule processing system. All of the properties listed above are present in any KRE system.

KRE is a container for [persistent compute objects](http://developer.kynetx.com/display/docs/Persistent+Compute+Objects) or picos. Each KRE instance hosts a number of picos. 

Picos ececute a rule-based programming langauge called KRL. 

- KRL is a rule-based language. 
- KRL primarily follows an event-based programming model. 
- KRL programs execute with a cloud-based model; there is no way to execute them from the command line.
- KRL programs are loaded from the cloud using HTTP. 
- KRL programs execute in a system where identity is pervasive; all events are raised on behalf of a specific entity.
- KRL programs have built-in, entity-specific persistent storage; there is no need for external databases.

The result of these properties is a programming model that more closely resembles programming cloud-based persistent objects. 

## Contributing

If you'd like to contribute, please [contact Phil Windley](http://www.windley.com/contact). Be sure to include your Github account name.

We use [HuBoard](https://huboard.com/kre/Kinetic-Rules-Engine) to organize and track issues. Once you have access to KRE you should be able to use HuBoard to watch issues. Anything in the *Ready* column should be ready to work. Please assign yourself and move it to the ready column. Do your work in a fork of the project and submit your changes as a pull request. 

The following process is recommended:

1. Fork the project and work on your own repository

2. Be sure to create tests that show the problem. The KRE test suite is quite good and we rely on it to ensure that changes don't cause existing features to work.

3. Submit a pull request to this project from your project with the changes.

Your pull request will be more easily integrated if you

1. include tests

2. be responsive to questions on the pull request

3. ensure you aren't duplicating some other work









