project = u'qiBuild'
version = '3.6-rc2'
sys.path.insert(0, os.path.abspath('../tools'))
# for autodoc
sys.path.insert(0, os.path.abspath('../../python'))
extensions.append("cmakedomain")
extensions.append("sphinx.ext.autodoc")

templates_path = [ "../source/_templates" ]

html_additional_pages = {
        'index': 'index.html'
}

autodoc_member_order='bysource'

exclude_patterns = ['man/*']

man_pages = [
    ('man/qisrc', 'qisrc', u'Handle several project sources',
     [u'Aldebaran Robotics'], 1),
    ('man/qibuild', 'qibuild', u'Configure, build, install, package your project',
     [u'Aldebaran Robotics'], 1),
    ('man/qitoolchain', 'qitoolchain', u'Hanlde sets of pre-compiled packges',
     [u'Aldebaran Robotics'], 1),
    ('man/qidoc', 'qidoc', u'Hanlde doxygen and sphinx projects',
     [u'Aldebaran Robotics'], 1),
    ('man/qilinguist', 'qilinguist', u'Translate projects using gettext or Qt linguist',
     [u'Aldebaran Robotics'], 1)
]

html_static_path = ['../source/_static']
