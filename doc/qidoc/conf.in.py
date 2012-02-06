project = u'qiBuild'
sys.path.insert(0, os.path.abspath('../tools'))
# for autodoc
sys.path.insert(0, os.path.abspath('../../python'))
extensions.append("cmakedomain")
extensions.append("sphinx.ext.autodoc")

man_pages = [
    ('ref/man/qisrc', 'qisrc', u'Handle several project sources',
     [u'Aldebaran Robotics'], 1),
    ('ref/man/qibuild', 'qibuild', u'Configure, build, install, package your project',
     [u'Aldebaran Robotics'], 1),
    ('ref/man/qitoolchain', 'qitoolchain', u'Hanlde sets of pre-compiled packges',
     [u'Aldebaran Robotics'], 1)
]
