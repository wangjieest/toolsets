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
import xml.etree.ElementTree as ET

import custom_rules

class cpplint_ex:
    def __init__(self, root_path, report_file):
        self.root_path = root_path
        self.report_file = report_file
        self.allfiles = []        

    def __walk(self, root_path, path):
        relative_path = path[len(root_path)-len(path)+1:]        
        if custom_rules.is_skip_path(relative_path) :
            print 'skip walk path : %s' %(relative_path)
            return

        target_subfixs = ['cc', 'cpp', 'cxx', 'h', 'hh', 'hpp', 'hxx']
        skip_items = ['.svn']        
        for item in os.listdir(path):
            if (item in skip_items):
                continue
            subpath = os.path.join(path, item)
            relative_file_path = subpath[len(root_path)-len(subpath)+1:]
            if (custom_rules.is_skip_file(relative_file_path)):
              continue
            mode = os.stat(subpath)[stat.ST_MODE]
            if (stat.S_ISDIR(mode)):
                self.__walk(root_path,subpath)
            elif subpath.rpartition('.')[2] in target_subfixs:
                print 'add file to list : ' + relative_file_path
                self.allfiles.append(subpath)
    
    def get_svn_url(self, file_name):
        strURL = "URL: "
        strRelativeURL = "Relative URL: "
        
        cmd = 'svn info %s'%(file_name)
        info = os.popen(cmd).read()
        if strURL in info:
            index1 = info.find(strURL)
            index2 = info.find(strRelativeURL)
            return info[index1+len(strURL) : index2-1]
        else:
            return ''

    def get_latest_modifier(self, file_name):    
        url = self.get_svn_url(file_name)
        #print url
        cmd = 'svn list %s --xml'%(url)
        xml = os.popen(cmd).read()
        
        try: 
            root = ET.fromstring(xml)        
            entries = root.findall('list/entry')
            if len(entries) == 1:
                author = entries[0].find('commit/author')
                return author.text
            else:
                return ''
        except Exception, e:
            print e
            return '' 

    def check(self, max_err_count=None):
        self.allfiles = []        
        self.__walk(self.root_path, self.root_path)
        if not self.allfiles:
          print "Error: no file is checked"
          return -1

        err_count_total = 0
        dict_file_errcount = {}
        dict_err_category = {}
        rootlen = len(self.root_path) + 1
        for filename in self.allfiles:
          try:
            googlestyle_cpplint._cpplint_state.SetCountingStyle('detailed')
            googlestyle_cpplint._cpplint_state.SetFilters(custom_rules.get_filters())
            googlestyle_cpplint._cpplint_state.ResetErrorCounts()
            print 'begin analyze file :%s' %(filename)
            googlestyle_cpplint.ProcessFile(filename, googlestyle_cpplint._cpplint_state.verbose_level)
            if (googlestyle_cpplint._cpplint_state.error_count > 0):
              dict_file_errcount[filename[rootlen: len(filename)]] = googlestyle_cpplint._cpplint_state.error_count
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
        
        #create xml report
        try:
            items = dict_file_errcount.items()
            backitems=[[v[1],v[0]] for v in items]
            backitems.sort()
            item_len = len(backitems)
            root = None
            dom = None
            try:
              dom = minidom.parse(self.report_file)
              root = dom.documentElement
            except:
              print 'out_file_name xml can not parse.'
              root = None
              dom = None

            if (None == root):
              impl = minidom.getDOMImplementation()
              dom = impl.createDocument(None,  'Root' , None)
              root = dom.documentElement

            try:
              node_rules = root.getElementsByTagName('CodeStyle')
              for node in node_rules:
                root.removeChild(node)
            except:
              print 'removeChild fail.'

            node_rule = dom.createElement('CodeStyle')
            node_rule.setAttribute('ErrFile', str(item_len))
            node_rule.setAttribute('Err', str(err_count_total))
            root.appendChild(node_rule)
            for i in range(0, item_len):
              node_line = dom.createElement('File')
              file_path = backitems[item_len-1-i][1]
              full_path = self.root_path + '\\' + file_path
              author = self.get_latest_modifier(full_path)
              node_line.setAttribute('Path', file_path+'(last modified by:'+author+')')
              node_line.setAttribute('Err', str(backitems[item_len-1-i][0]))
              
              if custom_rules.is_old_file(file_path)==False:
                    node_line.setAttribute('NewFile', '1')                    
              else :
                    node_line.setAttribute('NewFile', '0')
              node_rule.appendChild(node_line)
            #write catege begin
            items = dict_err_category.items()
            backitems=[[v[1],v[0]] for v in items]
            backitems.sort()
            item_len = len(backitems)
            for i in range(0, item_len):
              node_cat = dom.createElement('Category')
              node_cat.setAttribute('Name', backitems[item_len-1-i][1])
              node_cat.setAttribute('Err', str(backitems[item_len-1-i][0]))
              node_rule.appendChild(node_cat)
            #write catege end
            f = codecs.open(self.report_file, "w", "utf-8")
            dom.writexml(f, addindent='    ', newl='\r', encoding='utf-8')
            f.close()
        except Exception, e:
            print "Error: write CodeRule result err(%s)" %(str(e))
            return -2
        
        return 0


def main(root_path, report_file):
    """Analyze all files googlestyle_cpplint issues in folder and output a xml report.
    
    There must be a BLADE_ROOT file in the source root path
    
    Args:
        root_path: path of the source
        report_file: the report file path
    
    Reurns:
        0: successed
        otherwise: failed
        
    Example:
        cpplint_ex.py "d:\\dev\\client" "d:\\client_lint_report.xml"
    """
    cpplinter = cpplint_ex(root_path, report_file)
    return cpplinter.check()

main(sys.argv[1], sys.argv[2])