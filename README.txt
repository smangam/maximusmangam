
# first run setenv.rb program
this program gives you the option to choose the profile and region, and sets your credentials via the shared credentials file
this program also populates credentials.auto.tfvars file

# Note regarding terraform
this directory(/myprograms/aws) is the root module for terraform
always define all your variables in this directory (aka the root module)
each service must exist in its own sub-dir (the sub-dir is the module)
all variables must be defined in a auto.tfvars file in the root directory
do not define any variables in the modules
use the root module to call other modules. pass variables to the modules via arguments

