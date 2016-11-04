#check all files googlestyle_cpplint issues in folder and output a xml report
import os
import sys
sys.path.append('..\..\common\\tools')
#print sys.path
import googlestyle_cpplint
import xml
from xml.dom import minidom
import codecs
import stat
import platform

import custom_rules

class cpplint_ex:
    def __init__(self, file_path):
        self.allfiles = []
        self.allfiles.append(file_path)

    def check(self, max_err_count=None):
        err_count_total = 0
        dict_file_errcount = {}
        dict_err_category = {}
        #rootlen = len(self.root_path) + 1
        for filename in self.allfiles:
            try:
                googlestyle_cpplint._cpplint_state.SetOutputFormat('vs7')
                googlestyle_cpplint._cpplint_state.SetCountingStyle('detailed')
                googlestyle_cpplint._cpplint_state.SetFilters(custom_rules.get_filters())
                googlestyle_cpplint._cpplint_state.ResetErrorCounts()
                #print 'begin analyze file :%s' %(filename)
                googlestyle_cpplint.ProcessFile(filename, googlestyle_cpplint._cpplint_state.verbose_level)
                if (googlestyle_cpplint._cpplint_state.error_count > 0):
                  #dict_file_errcount[filename[rootlen: len(filename)]] = cpplint._cpplint_state.error_count
                  #record category begin
                    for cat, count in googlestyle_cpplint._cpplint_state.errors_by_category.iteritems():
                        if cat not in dict_err_category:
                            dict_err_category[cat] = 0
                        dict_err_category[cat] += count
                  #record category end"""
                    print 'error found in %s' %(filename)
                    err_count_total += googlestyle_cpplint._cpplint_state.error_count
            except Exception, e:
                print "Error: except when check file: %s, err:%s" %(filename, str(e))
            if (max_err_count <> None) and err_count_total > max_err_count:
                break

        print 'Total Error Count Is : %d' %err_count_total
        
        return 0


def main(file_path):
    """Analyze all files cpplint issues in folder and output a xml report.
    
    There must be a BLADE_ROOT file in the source root path
    
    Args:
        file_path: path of the source
    
    Reurns:
        0: successed
        otherwise: failed
        
    Example:
        cpplint_ex.py "d:\\dev\\client"
    """
    cpplinter = cpplint_ex(file_path)
    return cpplinter.check()

main(sys.argv[1])