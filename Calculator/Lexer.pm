#!/usr/bin/perl

package Calculator::Lexer;

use warnings;
use strict;

use Exporter qw(import);
our @EXPORT = qw();

use Carp;

use Calculator::Token;

sub new
{
  my $class = shift();

  my $self = {};
  $self->{text} = shift();
  $self->{file} = shift();
  $self->{pos} = 0;
  $self->{line} = 1;
  $self->{lpos} = 1;
  $self->{char} = substr($self->{text}, $self->{pos}, 1);

  bless($self, $class);
  return $self;
}


sub shout
{
  my $self = shift();
  my $message = shift();
  my $isError = shift();

  print $self->at() . ($isError ? ': error: ' : ': warning: ') . $message . "\n";
  $self->println($self->{line}, $self->{lpos});
  croak $message if ($isError);
}

sub warning
{
  shift()->shout(shift(), 0);
}

sub error
{
  shift()->shout(shift(), 1);
}

sub println
{
  my $self = shift();
  my $num = shift();

  my $pointer = shift();

  my $i = 1;
  my $index = 0;
  while ($i < $num)
  {
    $index = index($self->{text}. "\n", $index+1) + 1;
    ++$i;
  }
  my $line = substr($self->{text}, $index, index($self->{text}, "\n", $index) - $index);
  print "$line\n";

  if (defined($pointer))
  {
    $pointer -= 2; # take 1 for the 1 index, another to fit the claret
    print ' ' x $pointer if ($pointer > 0);
    print "^\n";
  }
}
# return what the next character is, without incrementing our position
sub peek
{
  my $self = shift();
  my $pos = $self->{pos} + 1;
  if ($pos >= length($self->{text}))
  {
    return undef;
  }
  return substr($self->{text}, $pos, 1);
}

# returns the line number and the position on the line
sub at
{
  my $self = shift();
  return $self->{line} . ':' . $self->{lpos};
}

# advance the pos pointer and set char to the next character to parse
# also controls line and position counting for at()
sub advance
{
  my $self = shift();

  $self->{pos}++;
  $self->{lpos}++;

  if ($self->{pos} >= length($self->{text}))
  {
    $self->{char} = undef;
  }
  else
  {
    $self->{char} = substr($self->{text}, $self->{pos}, 1);
    if ($self->{char} eq "\n")
    {
      $self->{line}++;
      $self->{lpos} = 1;
    }
  }
}

# skip over any whitespace using advance()
sub whitespace
{
  my $self = shift();

  while (defined $self->{char} && $self->{char} =~ /\s/)
  {
    $self->advance();
  }
}

sub _id
{
  my $self = shift();

  my $label = '';
  while (defined $self->{char} && $self->{char} =~ /^[\w]$/)
  {
    $label .= $self->{char};
    $self->advance();
  }
  if (defined $self->{char} && $self->{char} eq '(')
  {
    return Calculator::Token->new(FUNCTION, $label);
  }

  return Calculator::Token->new(ID, $label);
}

# parse a multidigit, floating point number out
sub number
{
  my $self = shift();

  my $n = '';
  if ($self->{char} eq '0' && $self->peek() eq 'x')
  {
    $self->advance();
    $self->advance();
    while (defined($self->{char}) && $self->{char} =~ /[\da-fA-F]/)
    {
      $n .= $self->{char};
      $self->advance();
    }
    return hex($n);
  }
  else
  {
    while (defined($self->{char}) && $self->{char} =~ /\d/)
    {
      $n .= $self->{char};
      $self->advance();
    }
    if (defined($self->{char}) && $self->{char} eq '.')
    {
      $n .= '.';
      $self->advance();
      while (defined($self->{char}) && $self->{char} =~ /\d/)
      {
        $n .= $self->{char};
        $self->advance();
      }
    }
    return $n+0; # coerce to a number
  }
}

# lexical analyser
sub next
{
  my $self = shift();

  while (defined $self->{char})
  {
    if ($self->{char} =~ /\s/)
    {
      $self->whitespace();
      next;
    }

    my $peek = $self->peek() || '';
    if (
        ($self->{char} eq '.' && $peek =~ /\d/) ||
        ($self->{char} eq '0' && $peek eq 'x') ||
        ($self->{char} =~ /\d/ && $peek ne 'x')
       )
    {
      return Calculator::Token->new(NUMBER, $self->number());
    }

    if ($self->{char} eq '+' && $self->peek() ne '=')
    {
      $self->advance();
      return Calculator::Token->new(ADDITION, '+');
    }
    if ($self->{char} eq '-' && $self->peek() ne '=')
    {
      $self->advance();
      return Calculator::Token->new(SUBTRACTION, '-');
    }

    if ($self->{char} eq '*' && ($self->peek() ne '*' && $self->peek() ne '='))
    {
      $self->advance();
      return Calculator::Token->new(MULTIPLY, '*');
    }
    if ($self->{char} eq '/' && $self->peek() ne '=')
    {
      $self->advance();
      return Calculator::Token->new(DIVIDE, '/');
    }
    if ($self->{char} eq '%' && $self->peek() ne '=')
    {
      $self->advance();
      return Calculator::Token->new(MODULO, '%');
    }


    if ($self->{char} eq '*' && $self->peek() eq '*')
    {
      $self->advance();
      $self->advance();
      return Calculator::Token->new(POWER, '**');
    }
    if ($self->{char} eq '!')
    {
      $self->advance();
      return Calculator::Token->new(FACTORIAL, '!');
    }

    if ($self->{char} eq '&' && $self->peek() ne '&')
    {
      $self->advance();
      return Calculator::Token->new(BITWISE_AND, '&');
    }
    if ($self->{char} eq '|' && $self->peek() ne '|')
    {
      $self->advance();
      return Calculator::Token->new(BITWISE_OR, '|');
    }
    if ($self->{char} eq '^')
    {
      $self->advance();
      return Calculator::Token->new(BITWISE_XOR, '^');
    }
    if ($self->{char} eq '~')
    {
      $self->advance();
      return Calculator::Token->new(BITWISE_NOT, '~');
    }
    if ($self->{char} eq '>' && $self->peek() eq '>')
    {
      $self->advance();
      $self->advance();
      return Calculator::Token->new(BITSHIFT_R, '>>');
    }
    if ($self->{char} eq '<' && $self->peek() eq '<')
    {
      $self->advance();
      $self->advance();
      return Calculator::Token->new(BITSHIFT_L, '<<');
    }

    if ($self->{char} eq '(')
    {
      $self->advance();
      return Calculator::Token->new(L_PARENTHESIS, '(');
    }
    if ($self->{char} eq ')')
    {
      $self->advance();
      return Calculator::Token->new(R_PARENTHESIS, ')');
    }
    if ($self->{char} =~ /^[\w]$/)
    {
      return $self->_id();
    }
    if ($self->{char} eq '=')
    {
      $self->advance();
      return Calculator::Token->new(ASSIGN, '=');
    }
    if ($self->{char} eq ';')
    {
      $self->advance();
      return Calculator::Token->new(SEMICOLON, ';');
    }
    if ($self->{char} eq ',')
    {
      $self->advance();
      return Calculator::Token->new(COMMA, ',');
    }

    # not returned anything but we're not at the end of the stream, so error out
    $self->error("unrecognized token: '" . $self->{char} . "'");
  }
  return Calculator::Token->new(EOF, undef);
}

# a bit ugly, but lets us peek at what the next token is
# which lets us see if a variable at the start of a statement is being used for
# assignment or as part of an expression
sub peekToken
{
  my $self = shift();
  my $backup = {%$self};

  my $tok = $self->next();
  $self->{text} = $backup->{text};
  $self->{file} = $backup->{file};
  $self->{pos} = $backup->{pos};
  $self->{line} = $backup->{line};
  $self->{lpos} = $backup->{lpos};
  $self->{char} = $backup->{char};
  return $tok;
}

1;
