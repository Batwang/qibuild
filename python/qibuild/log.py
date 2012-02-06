## Copyright (c) 2012 Aldebaran Robotics. All rights reserved.
## Use of this source code is governed by a BSD-style license that can be
## found in the COPYING file.
"""Few useful functions for logging,
featuring a loghandler using colors
(depends on pyreadline for this to work on windows)

"""

import sys
import logging
ON_WIN = sys.platform.startswith("win")

# Try using pyreadline so that we can
# have colors on windows, too.
HAS_PYREADLINE = True
if ON_WIN:
    try:
        # pylint: disable-msg=F0401
        from pyreadline.console import Console
    except ImportError:
        HAS_PYREADLINE = False

# Ansi colors
COLORS = {
    "bold"    :  "\033[1m"  ,
    "clear"   :  "\033[0m"  ,
    "red"     :  "\033[31m" ,
    "green"   :  "\033[32m" ,
    "blue"    :  "\033[34m" ,
}

if ON_WIN and not HAS_PYREADLINE:
    # simpy remove escape chars
    for k in COLORS.iterkeys():
        COLORS[k] = ""

# Make sure logging is configured only once:
LOG_CONFIG_DONE = False

class ColorLogHandler(logging.StreamHandler):
    """A class that outputs nice colored messages

    """
    # Warning:
    # Most of the code from logging's formatters is re-written in
    # ColorHandler.emit(), so using setFormatter would
    # have no effect on color logger...
    def __init__(self):
        logging.StreamHandler.__init__(self)
        if ON_WIN and HAS_PYREADLINE:
            self.console = Console()
        # Avoid printing colors if not a tty:
        if not sys.stdout.isatty():
            for k in COLORS.keys():
                COLORS[k] = ""
            self.console = None

    def emit(self, record):
        """Override StreamHandler.emit method

        """
        name  = record.name
        level = record.levelname
        mess  = record.getMessage()
        res   = COLORS["bold"]
        if record.levelno   == logging.DEBUG:
            res += COLORS["blue"]
        elif record.levelno == logging.INFO:
            res += COLORS["green"]
        elif record.levelno >= logging.WARNING:
            res += COLORS["red"]
        level = "[%s]" % level

        if record.levelno != logging.INFO:
            res += "%-12s"  % level
            res += "%-12s " % name
        res += mess
        res += COLORS["clear"]
        res += "\n"
        if ON_WIN and HAS_PYREADLINE:
            if self.console is not None:
                self.console.write_color(res)
            else:
                sys.stdout.write(res)
        else:
            if record.levelno < logging.WARNING:
                sys.stdout.write(res)
            else:
                sys.stderr.write(res)



def configure_logging(args):
    """Configure logging globally """
    global LOG_CONFIG_DONE
    if LOG_CONFIG_DONE:
        return
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.DEBUG)
    handler = None
    if args.color:
        handler = ColorLogHandler()
    else:
        handler = logging.StreamHandler()

    if args.verbose:
        handler.setLevel(logging.DEBUG)
    elif args.quiet:
        handler.setLevel(level=logging.ERROR)
        import qibuild.command
        qibuild.command.CONFIG["quiet"] = True
    else:
        handler.setLevel(level=logging.INFO)

    root_logger.addHandler(handler)
    LOG_CONFIG_DONE = True


def get_current_log_level():
    """Get the current log level.

    """
    # This looks a bit weird...
    root_logger = logging.getLogger()
    handlers = root_logger.handlers
    if handlers:
        return handlers[0].level
    else:
        return logging.INFO


def main():
    class Namespace:
        color = True
        verbose = False
        quiet = False
    args = Namespace()
    if "-v" in sys.argv:
        args.verbose = True
    if "-q" in sys.argv:
        args.quiet = True
    configure_logging(args)
    logger = logging.getLogger("foo.bar")
    logger.debug("debug")
    logger.info("info")
    logger.warning("warning")
    logger.error("error")

    print "current log level", get_current_log_level()


if __name__ == "__main__":
    main()
