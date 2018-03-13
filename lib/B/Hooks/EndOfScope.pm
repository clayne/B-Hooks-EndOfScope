package B::Hooks::EndOfScope;
# ABSTRACT: Execute code after a scope finished compilation
# KEYWORDS: code hooks execution scope

use strict;
use warnings;

our $VERSION = '0.22';

# note - a %^H tie() fallback will probably work on 5.6 as well,
# if you need to go that low - sane patches passing *all* tests
# will be gladly accepted
use 5.008001;

BEGIN {
  use Module::Implementation 0.05;
  Module::Implementation::build_loader_sub(
    implementations => [ 'XS', 'PP' ],
    symbols => [ 'on_scope_end' ],
  )->();
}

use Sub::Exporter::Progressive 0.001006 -setup => {
  exports => [ 'on_scope_end' ],
  groups  => { default => ['on_scope_end'] },
};

1;
__END__

=pod

=head1 SYNOPSIS

    on_scope_end { ... };

=head1 DESCRIPTION

This module allows you to execute code when perl finished compiling the
surrounding scope.

=func on_scope_end

    on_scope_end { ... };

    on_scope_end $code;

Registers C<$code> to be executed after the surrounding scope has been
compiled.

This is exported by default. See L<Sub::Exporter> on how to customize it.

=head1 LIMITATIONS

=head2 Pure-perl mode caveat

This caveat applies to B<any> version of perl where L<Variable::Magic>
is unavailable or otherwise disabled.

While L<Variable::Magic> has access to some very dark sorcery to make it
possible to throw an exception from within a callback, the pure-perl
implementation does not have access to these hacks. Therefore, what
would have been a B<compile-time exception> is instead B<converted to a
warning>, and your execution will continue as if the exception never
happened.

To explicitly request an XS (or PP) implementation one has two choices. Either
to import from the desired implementation explicitly:

 use B::Hooks::EndOfScope::XS
   or
 use B::Hooks::EndOfScope::PP

or by setting C<$ENV{B_HOOKS_ENDOFSCOPE_IMPLEMENTATION}> to either C<XS> or
C<PP>.

=head2 Perl 5.8.0 ~ 5.8.3

Due to a L<core interpreter bug
|https://rt.perl.org/Public/Bug/Display.html?id=27040#txn-82797> present in
older perl versions, the implementation of B::Hooks::EndOfScope deliberately
leaks a single empty hash for every scope being cleaned. This is done to
avoid the memory corruption associated with the bug mentioned above.

In order to stabilize this workaround use of L<Variable::Magic> is disabled
on perls prior to version 5.8.4. On such systems loading/requesting
L<B::Hooks::EndOfScope::XS> explicitly will result in a compile-time
exception.

=head1 SEE ALSO

L<Sub::Exporter>

L<Variable::Magic>

=cut
