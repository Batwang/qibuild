import os
import qipkg.parsers

def test_pml_parser(qipkg_action, args):
    qipkg_action.add_test_project("a_cpp")
    qipkg_action.add_test_project("d_pkg")
    meta_pkg_proj = qipkg_action.add_test_project("meta_pkg")
    args.pml_path = os.path.join(meta_pkg_proj.path, "meta_pkg.mpml")
    meta_builder = qipkg.parsers.get_pml_builder(args)
    assert len(meta_builder.pml_builders) == 2
    [a_pml, d_pml] = meta_builder.pml_builders
    assert len(a_pml.cmake_builder.projects) == 1
    assert len(d_pml.cmake_builder.projects) == 0

def test_reads_build_config(qipkg_action, args, toolchains):

    toolchains.create("foo")
    qipkg_action.add_test_project("a_cpp")
    qipkg_action.add_test_project("d_pkg")
    meta_pkg_proj = qipkg_action.add_test_project("meta_pkg")
    args.config = "foo"
    args.pml_path = os.path.join(meta_pkg_proj.path, "meta_pkg.mpml")
    meta_builder = qipkg.parsers.get_pml_builder(args)
    a_pml_builder = meta_builder.pml_builders[0]
    build_config = a_pml_builder.build_worktree.build_config
    assert build_config.active_config == "foo"
