FROM ghcr.io/crytic/echidna/echidna:testing-master@sha256:fa1c36ac72e3a0b55383d24b63e9cb53acd9b623e58d2bbf7e69a81a122f9a35

WORKDIR /src
COPY ./Person.sol .
COPY ./PersonSolutionPart2.sol .
COPY ./echidna.yaml .

CMD ["echidna", "PersonSolutionPart2.sol", "--contract", "Person"]
CMD ["sleep", "1d"]