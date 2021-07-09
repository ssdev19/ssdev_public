# for all drupal
class profile::drupal {
  # include drush::drush
  drush::drush { 'drush8':
  version => '8',
}
}
