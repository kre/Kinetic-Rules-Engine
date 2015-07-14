
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

## Project Roadmap

### Picos

## Using the Rules Engine

You can use the rules engine by createing an [account on the server that Pico Labs maintains](https://accounts.kobj.net/login).

Further instructions are available at the [Quickstart](http://developer.kynetx.com/display/docs/Quickstart). 

## Running the Rules Engine

There is currently no good way for developers to host their own instance of KRE. There is a Docker project in the roadmap that will allow this. 

## Contributing

If you'd like to contribute, please [contact Phil Windley](http://xri.net/=windley). Be sure to include your Github account name.

We use [HuBoard](https://huboard.com/kre/Kinetic-Rules-Engine) to organize and track issues. Once you have access to KRE you should be able to use HuBoard to watch issues. Anything in the *Ready* column should be ready to work. Please assign yourself and move it to the ready column. Do your work in a fork of the project and submit your changes as a pull request. 

The following process is recommended:

1. Fork the project and work on your own repository

2. Be sure to create tests that show the problem. The KRE test suite is quite good and we rely on it to ensure that changes don't cause existing features to work.

3. Submit a pull request to this project from your project with the changes.

Your pull request will be more easily integrated if you

1. include tests

2. be responsive to questions on the pull request

3. ensure you aren't duplicating some other work









