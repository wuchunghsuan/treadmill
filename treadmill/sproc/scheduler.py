"""Treadmill master scheduler."""


import click

from treadmill import context
from treadmill import master
from treadmill import scheduler


def init():
    """Return top level command handler."""

    @click.command()
    @click.argument('events-dir', type=click.Path(exists=True))
    @click.option('--vendor', type=click.Choice(['native', 'k8s']), default='native')
    def run(events_dir, vendor):
        """Run Treadmill master scheduler."""
        scheduler.DIMENSION_COUNT = 3
        cell_master = master.Master(context.GLOBAL.zk.conn,
                                    context.GLOBAL.cell,
                                    vendor, events_dir)
        cell_master.run()

    return run
