# namensschild

Little script to create and print name badges on a octoprint
instance with a little GUI.


Dependencies:

* openScad
* jq
* Droid Sans Mono
* zenity

GUI allows to input up to 3 names. Badge lenght and font size is dependend
on name lenght.

From help::

    $ create_scad --help
    create and print a label with arbitrary text, emphased as 3D object

    see https://github.com/planraum/nameshield
    
    Dependencies: 
     * openScad
     * jq (json handling in command line)
     * Droid Sans Mono font (must be recent enough)
    
    Usage
    
      create_scad.sh -o OCTO -a APIKEY [-t TEMPLATE] [-p PROFILE] [-s SLICER] [-h]
    
      -a|--apikey APIKEY         Octoprint server API key
    
      -o|--octo OCTO             Octoprint server
    
      -t|--template TEMPLATE     Which openScad template to use. Default 
                                   Anhaenger.template.scad
    
      -s|--slicer SLICER         Slicer to use on octoprint server. Default slic3r
    
      -p|--profile PROFILE       Slicer profile to use. Default prusa-0.15-pla-1.75
    
      -h|--help                  This help


