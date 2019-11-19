MATLAB Builder JA Read Me

1. Prerequisites for Deployment 

. Verify the MATLAB Compiler Runtime (MCR) is installed and ensure you    
  have installed version 7.17 (R2012a). 

. If the MCR is not installed, do following:
  (1) enter
  
      >>mcrinstaller
      
      at MATLAB prompt. This MCR Installer command displays the 
      location of the MCR Installer.

  (2) run the MCR Installer.

Or download Windows 64bit version of MCR from the MathWorks website:

   http://www.mathworks.com/products/compiler/
   
 
For more information about the MCR and the MCR Installer, see 
“Working With the MCR” in the MATLAB Compiler User’s Guide.

. Ensure you have the version (1.6.0) of the Java Runtime Environment (JRE). See section 
  5A.

. TLLibrary.jar must be included in your CLASSPATH.

. javabuilder.jar must be included in your CLASSPATH. javabuilder.jar 
  can be found in: 
  
  <mcr_root>*\toolbox\javabuilder\jar\win64\javabuilder.jar
  

NOTE: You will need administrator rights to run MCRInstaller. 
 
2. Files to Deploy and Package

-TLLibrary.jar
-MCRInstaller.exe 
   - include when building component by clicking "Add MCR" link 
     in deploytool
-Javadoc   
   - javadoc for TLLibrary is in the doc directory. While  
     distributing the javadoc, this entire directory should be distributed.
-This readme file


3. Resources

To learn more about:			See:
=================================================================================
Deploying Java applications on the Web 	MATLAB Builder JA User's Guide
Examples of Java Web Applications 	Application Deployment Web Example Guide      


4. Definitions

For information on deployment terminology, go to 
http://www.mathworks.com/help. Select your product and see 
the Glossary in the User’s Guide.


* NOTE: <mcr_root> is the directory where MCR is installed on the target machine.


5. Appendix 

A. Linux systems:
   On the target machine, add the MCR directory to the environment variable 
   LD_LIBRARY_PATH by issuing the following commands:

        NOTE: <mcr_root> is the directory where MCR is installed
              on the target machine.         

            setenv LD_LIBRARY_PATH
                $LD_LIBRARY_PATH:
                <mcr_root>/v717/runtime/glnx86:
                <mcr_root>/v717/bin/glnx86:
                <mcr_root>/v717/sys/os/glnx86:
                <mcr_root>/v717/sys/java/jre/glnx86/jre/lib/i386/native_threads:
                <mcr_root>/v717/sys/java/jre/glnx86/jre/lib/i386/server:
                <mcr_root>/v717/sys/java/jre/glnx86/jre/lib/i386
            setenv XAPPLRESDIR <mcr_root>/v717/X11/app-defaults
   
B. Linux x86-64 systems:   
   On the target machine, add the MCR directory to the environment variable 
   LD_LIBRARY_PATH by issuing the following commands:

        NOTE: <mcr_root> is the directory where MCR is installed
              on the target machine.         

            setenv LD_LIBRARY_PATH
                $LD_LIBRARY_PATH:
                <mcr_root>/v717/runtime/glnxa64:
                <mcr_root>/v717/bin/glnxa64:
                <mcr_root>/v717/sys/os/glnxa64:
                <mcr_root>/v717/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:
                <mcr_root>/v717/sys/java/jre/glnxa64/jre/lib/amd64/server:
                <mcr_root>/v717/sys/java/jre/glnxa64/jre/lib/amd64 
            setenv XAPPLRESDIR <mcr_root>/v717/X11/app-defaults
 
C. Mac systems: 
   On the target machine, add the MCR directory to the environment variable 
   DYLD_LIBRARY_PATH by issuing the following commands:

        NOTE: <mcr_root> is the directory where MCR is installed
              on the target machine.         

            setenv DYLD_LIBRARY_PATH
                $DYLD_LIBRARY_PATH:
                <mcr_root>/v717/runtime/maci64:
                <mcr_root>/v717/sys/os/maci64:
                <mcr_root>/v717/bin/maci64:
                /System/Library/Frameworks/JavaVM.framework/JavaVM:
                /System/Library/Frameworks/JavaVM.framework/Libraries
            setenv XAPPLRESDIR <mcr_root>/v717/X11/app-defaults


   For more detail information about setting MCR path on Mac, see "Deploying Your 
   Application on Mac or Linux" in Appendix "Using MATLAB Compiler on Mac or Linux" in 
   the MATLAB Compiler User's Guide.


       
        NOTE: To make these changes persistent after logout on Linux or 
              Mac machines, modify the .cshrc file to include this  
              setenv command.
        NOTE: On Windows, the environment variable syntax utilizes 
              backslashes (\), delimited by semi-colons (;). 
              On Linux or Mac, the environment variable syntax utilizes   
              forward slashes (/), delimited by colons (:).  
        NOTE: On Maci64, ensure you are using 64-bit JVM.
