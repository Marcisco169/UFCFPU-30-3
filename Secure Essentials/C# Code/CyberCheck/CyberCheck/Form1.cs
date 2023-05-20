using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Net.WebRequestMethods;

namespace CyberCheck
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        public static bool IsAdministrator()
        {
            //Checks if the app is running as admin.
            return (new WindowsPrincipal(WindowsIdentity.GetCurrent()))
                      .IsInRole(WindowsBuiltInRole.Administrator);
        }

        private void startButton_Click(object sender, EventArgs e)
        {
            if (!IsAdministrator()) {
                //If IsAdmin is false then show this message box.
                MessageBox.Show("Please run this app as Administrator", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }

            else
            {
                //If the user is admin, run the scripts.

                string path = @"\PowershellScripts\MasterExecute.ps1"; 
                //This is the location of the scripts where the executable is being run.

                var directory = Directory.GetCurrentDirectory(); 
                //This is the current location where the executable is being run.

                var ps1File = directory + path; 
                //Final path of the location of the sript to be run.

                var startInfo = new ProcessStartInfo()
                {
                    FileName = @"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
                    Arguments = $"-NoProfile -ExecutionPolicy unrestricted -File \"{ps1File}\"",
                    UseShellExecute = false
                    //The process is started directly by the application itself, without involving the shell.
                };
                Process.Start(startInfo);
            }
        }

        private void logButton_Click(object sender, EventArgs e)
        {
            string directoryPath = @".";
            //This is the current directory where the app was executed

            string partialFileName = "Log_"; 
            //This is the file which is being searched for

            string[] matchingFiles = Directory.GetFiles(directoryPath, partialFileName + "*");
            //Searching for the file with a wild card at the end as a date is appended to the name

            if (matchingFiles.Length > 0)
            {
                //This ensure that matchingFiles is not 0, then a file was found

                string filePath = matchingFiles[0];
                System.Diagnostics.Process.Start(filePath);
                //Open the found file
            }
            else
            {
                MessageBox.Show("No log file found!", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                //If the file is not found, let the user know
            }
        }

        private void reportButton_Click(object sender, EventArgs e)
        {
            string directoryPath = @".";
            //This is the current directory where the app was executed

            string partialFileName = "Cyber_Essentials_Hardening_Report_";
            //This is the file which is being searched for
            
            string[] matchingFiles = Directory.GetFiles(directoryPath, partialFileName + "*");
            //Searching for the file with a wild card at the end as a date is appended to the name

            if (matchingFiles.Length > 0)
            {
                //This ensure that matchingFiles is not 0, then a file was found

                string filePath = matchingFiles[0];
                System.Diagnostics.Process.Start(filePath);
                //Open the found file
            }
            else
            {
                MessageBox.Show("No report file found!", "Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
                //If the file is not found, let the user know
            }
        }
    }
}
