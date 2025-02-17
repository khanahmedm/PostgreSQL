
CREATE INDEX "bookings.memid_facid"
  ON cd.bookings
  USING btree
  (memid, facid);

CREATE INDEX "bookings.facid_memid"
  ON cd.bookings
  USING btree
  (facid, memid);

CREATE INDEX "bookings.facid_starttime"
  ON cd.bookings
  USING btree
  (facid, starttime);

CREATE INDEX "bookings.memid_starttime"
  ON cd.bookings
  USING btree
  (memid, starttime);

CREATE INDEX "bookings.starttime"
  ON cd.bookings
  USING btree
  (starttime);

CREATE INDEX "members.joindate"
  ON cd.members
  USING btree
  (joindate);

CREATE INDEX "members.recommendedby"
  ON cd.members
  USING btree
  (recommendedby);

ANALYZE;