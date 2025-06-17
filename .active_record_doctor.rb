ActiveRecordDoctor.configure do
  # Global settings affect all detectors.
  global :ignore_tables, [
    # Ignore internal Rails-related tables.
    "ar_internal_metadata",
    "schema_migrations",
    "active_storage_blobs",
    "active_storage_attachments",
    "action_text_rich_texts",

    # Ignore SolidCable tables.
    /^solid_cable_/,

    # Ignore SolidCache tables.
    /^solid_cache_/,

    # Ignore SolidQueue tables.
    /^solid_queue_/,

    # Ignore SolidErrors tables.
    /^solid_errors_/,

    # Ignore PgHero tables.
    /^pghero_/
  ]

  global :ignore_models, [
    # Ignore internal Rails-related models.
    /^ActionMailbox::/,
    /^ActionText::/,
    /^ActiveStorage::/,

    # Ignore SolidCable models.
    /^SolidCable::/,

    # Ignore SolidCache models.
    /^SolidCache::/,

    # Ignore SolidQueue models.
    /^SolidQueue::/,

    # Ignore SolidErrors models.
    /^SolidErrors::/
  ]
end
