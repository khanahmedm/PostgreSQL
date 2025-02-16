--
-- TOC entry 2196 (class 2606 OID 32822)
-- Name: bookings_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pk PRIMARY KEY (bookid);


--
-- TOC entry 2192 (class 2606 OID 32777)
-- Name: facilities_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pk PRIMARY KEY (facid);


--
-- TOC entry 2194 (class 2606 OID 32807)
-- Name: members_pk; Type: CONSTRAINT; Schema: cd; Owner: -; Tablespace:
--

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pk PRIMARY KEY (memid);


--
-- TOC entry 2198 (class 2606 OID 32823)
-- Name: fk_bookings_facid; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_bookings_facid FOREIGN KEY (facid) REFERENCES facilities(facid);


--
-- TOC entry 2199 (class 2606 OID 32828)
-- Name: fk_bookings_memid; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_bookings_memid FOREIGN KEY (memid) REFERENCES members(memid);


--
-- TOC entry 2197 (class 2606 OID 32808)
-- Name: fk_members_recommendedby; Type: FK CONSTRAINT; Schema: cd; Owner: -
--

ALTER TABLE ONLY members
    ADD CONSTRAINT fk_members_recommendedby FOREIGN KEY (recommendedby) REFERENCES members(memid) ON DELETE SET NULL;
